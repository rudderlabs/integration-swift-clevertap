//
//  CleverTapUtilsTests.swift
//  RudderIntegrationCleverTapTests
//

import Testing
import Foundation
@testable import RudderIntegrationCleverTap

@Suite
struct CleverTapUtilsTests {

    // MARK: - Profile Tests

    @Test("given an empty userId, when buildProfile is called, then no Identity is set")
    func testProfileWithEmptyUserId() {
        let profile = CleverTapUtils.buildProfile(userId: "", traits: [:])

        #expect(profile["Identity"] == nil)
        #expect(profile.isEmpty)
    }

    @Test("given a userId trait, when buildProfile is called, then the trait is dropped")
    func testProfileDropsUserIdTrait() {
        let profile = CleverTapUtils.buildProfile(userId: "user-1", traits: ["userId": "user-1"])

        #expect(profile["Identity"] as? String == "user-1")
        #expect(profile["userId"] == nil)
    }

    @Test("given a male gender, when buildProfile is called, then the gender is M", arguments: ["male", "Male", "m", "M"])
    func testProfileMaleGender(_ gender: String) {
        let profile = CleverTapUtils.buildProfile(userId: nil, traits: ["gender": gender])

        #expect(profile["Gender"] as? String == "M")
        #expect(profile["gender"] == nil)
    }

    @Test("given a female gender, when buildProfile is called, then the gender is F", arguments: ["female", "FEMALE", "f", "F"])
    func testProfileFemaleGender(_ gender: String) {
        let profile = CleverTapUtils.buildProfile(userId: nil, traits: ["gender": gender])

        #expect(profile["Gender"] as? String == "F")
    }

    @Test("given an unknown gender, when buildProfile is called, then no gender is set")
    func testProfileUnknownGender() {
        let profile = CleverTapUtils.buildProfile(userId: nil, traits: ["gender": "other"])

        #expect(profile["Gender"] == nil)
        #expect(profile["gender"] == nil)
    }

    @Test("given a non string gender, when buildProfile is called, then the trait is kept as is")
    func testProfileNonStringGender() {
        let profile = CleverTapUtils.buildProfile(userId: nil, traits: ["gender": 1])

        #expect(profile["Gender"] == nil)
        #expect(profile["gender"] as? Int == 1)
    }

    @Test("given a birthday string, when buildProfile is called, then the DOB is a date")
    func testProfileBirthdayString() throws {
        let profile = CleverTapUtils.buildProfile(userId: nil, traits: ["birthday": "1990-05-17"])

        let dob = try #require(profile["DOB"] as? Date)
        let components = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: dob)
        #expect(components.year == 1990)
        #expect(components.month == 5)
        #expect(components.day == 17)
        #expect(profile["birthday"] == nil)
    }

    @Test("given a birthday date, when buildProfile is called, then the DOB is the same date")
    func testProfileBirthdayDate() {
        let birthday = Date(timeIntervalSince1970: 643_000_000)
        let profile = CleverTapUtils.buildProfile(userId: nil, traits: ["birthday": birthday])

        #expect(profile["DOB"] as? Date == birthday)
    }

    @Test("given an unparsable birthday, when buildProfile is called, then no DOB is set")
    func testProfileInvalidBirthday() {
        let profile = CleverTapUtils.buildProfile(userId: nil, traits: ["birthday": "17/05/1990"])

        #expect(profile["DOB"] == nil)
        #expect(profile["birthday"] == nil)
    }

    @Test("given a numeric phone, when buildProfile is called, then the phone is a string")
    func testProfileNumericPhone() {
        let profile = CleverTapUtils.buildProfile(userId: nil, traits: ["phone": 919_876_543_210])

        #expect(profile["Phone"] as? String == "919876543210")
    }

    @Test("given a company trait, when buildProfile is called, then the nested values are flattened")
    func testProfileFlattensCompany() {
        let profile = CleverTapUtils.buildProfile(userId: nil, traits: [
            "company": ["id": "company-1", "name": "RudderStack", "industry": "Software"]
        ])

        #expect(profile["companyId"] as? String == "company-1")
        #expect(profile["companyName"] as? String == "RudderStack")
        #expect(profile["industry"] as? String == "Software")
        #expect(profile["company"] == nil)
    }

    @Test("given an address trait, when buildProfile is called, then the nested values are flattened", arguments: ["address", "adderess"])
    func testProfileFlattensAddress(_ key: String) {
        let profile = CleverTapUtils.buildProfile(userId: nil, traits: [
            key: ["city": "Bengaluru", "country": "India"]
        ])

        #expect(profile["city"] as? String == "Bengaluru")
        #expect(profile["country"] as? String == "India")
    }

    @Test("given an unsupported nested trait, when buildProfile is called, then the trait is dropped")
    func testProfileDropsUnsupportedNestedTrait() {
        let profile = CleverTapUtils.buildProfile(userId: nil, traits: [
            "preferences": ["theme": "dark"]
        ])

        #expect(profile["preferences"] == nil)
        #expect(profile["theme"] == nil)
    }

    // MARK: - Charged Event Tests

    @Test("given order properties, when buildChargedEvent is called, then the keys are mapped")
    func testChargedEventKeyMapping() {
        let result = CleverTapUtils.buildChargedEvent(from: [
            "order_id": "order-1",
            "revenue": 10.5,
            "coupon": "SAVE"
        ])

        #expect(result.details["Charged ID"] as? String == "order-1")
        #expect(result.details["Amount"] as? Double == 10.5)
        #expect(result.details["coupon"] as? String == "SAVE")
        #expect(result.details["order_id"] == nil)
        #expect(result.details["revenue"] == nil)
        #expect(result.items.isEmpty)
    }

    @Test("given nested properties, when buildChargedEvent is called, then they are dropped")
    func testChargedEventDropsNestedValues() {
        let result = CleverTapUtils.buildChargedEvent(from: [
            "nested": ["key": "value"],
            "list": [1, 2, 3],
            "flat": "kept"
        ])

        #expect(result.details["nested"] == nil)
        #expect(result.details["list"] == nil)
        #expect(result.details["flat"] as? String == "kept")
    }

    @Test("given an empty products array, when buildChargedEvent is called, then no items are built")
    func testChargedEventWithEmptyProducts() {
        let result = CleverTapUtils.buildChargedEvent(from: ["products": [Any]()])

        #expect(result.items.isEmpty)
        #expect(result.details["products"] == nil)
    }

    @Test("given products, when buildProductList is called, then the product_id is renamed")
    func testProductListRenamesProductId() {
        let items = CleverTapUtils.buildProductList(from: [
            ["product_id": "p1", "price": 10],
            ["product_id": "p2", "name": "Item"],
            "not-a-product"
        ])

        #expect(items.count == 2)
        #expect(items[0]["id"] as? String == "p1")
        #expect(items[0]["price"] as? Int == 10)
        #expect(items[1]["id"] as? String == "p2")
        #expect(items[1]["name"] as? String == "Item")
    }
}
