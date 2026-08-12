//
//  CleverTapUtils.swift
//  RudderIntegrationCleverTap
//
//  Constants and payload transformations for the CleverTap integration.
//

import Foundation

// MARK: - CleverTapConstants

/**
 The constants used by the CleverTap integration.
 */
enum CleverTapConstants {

    // Destination configuration keys
    static let accountId = "accountId"
    static let accountToken = "accountToken"
    static let region = "region"

    /// The dashboard sends this value when the user selects no region.
    static let noRegion = "none"

    /// The ecommerce event that CleverTap receives as a charged event.
    static let orderCompleted = "Order Completed"

    /// The prefix that CleverTap expects for a screen event.
    static let screenEventPrefix = "Screen Viewed: "
}

// MARK: - CleverTapUtils

/**
 The payload transformations that the CleverTap integration applies.
 */
enum CleverTapUtils {

    // Trait keys
    private static let userIdTrait = "userId"
    private static let emailTrait = "email"
    private static let nameTrait = "name"
    private static let phoneTrait = "phone"
    private static let genderTrait = "gender"
    private static let birthdayTrait = "birthday"
    private static let idKey = "id"

    /// The trait keys whose nested values CleverTap receives as flat profile attributes.
    private static let flattenedTraits = ["adderess", "address", "company"]

    // Profile keys
    private static let identityKey = "Identity"
    private static let emailKey = "Email"
    private static let nameKey = "Name"
    private static let phoneKey = "Phone"
    private static let genderKey = "Gender"
    private static let birthdayKey = "DOB"
    private static let companyIdKey = "companyId"
    private static let companyNameKey = "companyName"

    // Charged event keys
    private static let productsKey = "products"
    private static let productIdKey = "product_id"
    private static let orderIdKey = "order_id"
    private static let revenueKey = "revenue"
    private static let chargedIdKey = "Charged ID"
    private static let amountKey = "Amount"

    /// The date format that CleverTap expects for the date of birth.
    private static let birthdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /**
     Builds a CleverTap profile from the identify payload.

     CleverTap accepts only primitive types, dates, string arrays, and the flattened address
     and company attributes. This method drops every other nested value.

     - Parameters:
        - userId: The user identifier.
        - traits: The user traits.
     - Returns: The CleverTap profile attributes.
     */
    static func buildProfile(userId: String?, traits: [String: Any]) -> [String: Any] {
        var remainingTraits = traits
        var profile: [String: Any] = [:]

        remainingTraits.removeValue(forKey: userIdTrait)
        if let userId, !userId.isEmpty {
            profile[identityKey] = userId
        }

        if let email = remainingTraits.removeValue(forKey: emailTrait) {
            profile[emailKey] = email
        }

        if let name = remainingTraits.removeValue(forKey: nameTrait) {
            profile[nameKey] = name
        }

        if let phone = remainingTraits.removeValue(forKey: phoneTrait) {
            profile[phoneKey] = "\(phone)"
        }

        addGender(from: &remainingTraits, to: &profile)
        addBirthday(from: &remainingTraits, to: &profile)
        addRemainingTraits(remainingTraits, to: &profile)

        return profile
    }

    /**
     Builds the charge details and the item list of a CleverTap charged event.

     - Parameter properties: The `Order Completed` event properties.
     - Returns: The charge details and the purchased items.
     */
    static func buildChargedEvent(from properties: [String: Any]) -> (details: [String: Any], items: [[String: Any]]) {
        var details: [String: Any] = [:]
        var items: [[String: Any]] = []

        for (key, value) in properties {
            if key == productsKey {
                if let products = value as? [Any], !products.isEmpty {
                    items = buildProductList(from: products)
                }
                continue
            }

            // CleverTap does not accept nested values in the charge details.
            if value is [String: Any] || value is [Any] {
                continue
            }

            switch key {
            case orderIdKey:
                details[chargedIdKey] = value
            case revenueKey:
                details[amountKey] = value
            default:
                details[key] = value
            }
        }

        return (details, items)
    }

    /**
     Builds the CleverTap item list from the products of an `Order Completed` event.

     - Parameter products: The products of the event.
     - Returns: The items, with `product_id` renamed to `id`.
     */
    static func buildProductList(from products: [Any]) -> [[String: Any]] {
        return products.compactMap { $0 as? [String: Any] }.map { product in
            var transformedProduct: [String: Any] = [:]
            for (key, value) in product {
                transformedProduct[key == productIdKey ? idKey : key] = value
            }
            return transformedProduct
        }
    }

    // MARK: - Private Helpers

    /**
     Adds the gender attribute to the profile. CleverTap accepts only `M` and `F`.

     - Parameters:
        - traits: The remaining traits.
        - profile: The profile under construction.
     */
    private static func addGender(from traits: inout [String: Any], to profile: inout [String: Any]) {
        guard let gender = traits[genderTrait] as? String else { return }
        traits.removeValue(forKey: genderTrait)

        switch gender.lowercased() {
        case "male", "m":
            profile[genderKey] = "M"
        case "female", "f":
            profile[genderKey] = "F"
        default:
            break
        }
    }

    /**
     Adds the date of birth to the profile. CleverTap accepts a `Date` value only.

     - Parameters:
        - traits: The remaining traits.
        - profile: The profile under construction.
     */
    private static func addBirthday(from traits: inout [String: Any], to profile: inout [String: Any]) {
        if let birthday = traits[birthdayTrait] as? String {
            traits.removeValue(forKey: birthdayTrait)
            if let date = birthdayFormatter.date(from: birthday) {
                profile[birthdayKey] = date
            }
        } else if let birthday = traits[birthdayTrait] as? Date {
            traits.removeValue(forKey: birthdayTrait)
            profile[birthdayKey] = birthday
        }
    }

    /**
     Adds the remaining traits to the profile.

     The method copies each flat value. It flattens the address and the company traits. It drops
     every other nested value, because CleverTap does not accept it.

     - Parameters:
        - traits: The remaining traits.
        - profile: The profile under construction.
     */
    private static func addRemainingTraits(_ traits: [String: Any], to profile: inout [String: Any]) {
        for (key, value) in traits {
            guard let nestedMap = value as? [String: Any] else {
                profile[key] = value
                continue
            }

            guard flattenedTraits.contains(key) else { continue }

            for (nestedKey, nestedValue) in nestedMap {
                switch nestedKey {
                case idKey:
                    profile[companyIdKey] = nestedValue
                case nameTrait:
                    profile[companyNameKey] = nestedValue
                default:
                    profile[nestedKey] = nestedValue
                }
            }
        }
    }
}
