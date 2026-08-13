//
//  CleverTapExampleApp.swift
//  Example
//
//  Sample app for the RudderStack CleverTap device mode integration.
//

import SwiftUI
import Combine
import RudderStackAnalytics
import RudderIntegrationCleverTap

@main
struct CleverTapExampleApp: App {

    init() {
        setupAnalytics()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func setupAnalytics() {
        LoggerAnalytics.logLevel = .verbose

        let configuration = Configuration(
            writeKey: "<WRITE_KEY>",
            dataPlaneUrl: "<DATA_PLANE_URL>"
        )

        let analytics = Analytics(configuration: configuration)

        let integration = CleverTapIntegration()
        analytics.add(plugin: integration)

        AnalyticsManager.shared.analytics = analytics
    }
}

class AnalyticsManager {
    static let shared = AnalyticsManager()
    var analytics: Analytics?

    private init() {}
}

extension AnalyticsManager {

    // MARK: - User Identity

    func identifyUser() {
        // The birthday accepts a `Date`, a `yyyy-MM-dd` string, or an ISO 8601 string.
        let traits: [String: Any] = [
            "name": "RudderStack iOS",
            "email": "testuseriOS@example.com",
            "phone": "+919876543210",
            "gender": "M",
            "birthday": "1992-05-24",
            "Employed": "Y",
            "Education": "Graduate",
            "Married": "Y",
            "Age": 28,
            "Tz": "Asia/Kolkata",
            "Photo": "www.foobar.com/image.jpeg",
            "address": [
                "city": "Kolkata",
                "country": "India"
            ],
            "key-1": "value-1",
            "key-2": 1234
        ]

        analytics?.identify(userId: "rudderstack_ios_4", traits: traits)
        LoggerAnalytics.debug("Identified user with traits")
    }

    /// Identify with no traits. CleverTap receives the user identifier as `Identity` only.
    func identifyUserIdOnly() {
        analytics?.identify(userId: "rudderstack_ios_4")
        LoggerAnalytics.debug("Identified user without traits")
    }

    /// The gender `FEMALE` maps to `F`. The `id` trait stays a custom attribute.
    func identifyUserWithFemaleGender() {
        let traits: [String: Any] = [
            "name": "RudderStack iOS Female",
            "gender": "FEMALE",
            "id": "explicit-identity-1234"
        ]

        analytics?.identify(userId: "rudderstack_ios_6", traits: traits)
        LoggerAnalytics.debug("Identified user with a female gender")
    }

    /// An out-of-range birthday. CleverTap must receive no `DOB`. A lenient parser would roll the
    /// value over to 1991-02-14 and write a wrong date onto the profile.
    func identifyUserWithOutOfRangeBirthday() {
        let traits: [String: Any] = [
            "name": "Birthday Probe Out Of Range",
            "birthday": "1990-13-45"
        ]

        analytics?.identify(userId: "rudderstack_ios_birthday_probe", traits: traits)
        LoggerAnalytics.debug("Identified user with an out of range birthday")
    }

    /// A birthday in the wrong format. CleverTap must receive no `DOB` and no raw `birthday` key.
    func identifyUserWithMalformedBirthday() {
        let traits: [String: Any] = [
            "name": "Birthday Probe Malformed",
            "birthday": "01/02/1990"
        ]

        analytics?.identify(userId: "rudderstack_ios_birthday_probe", traits: traits)
        LoggerAnalytics.debug("Identified user with a malformed birthday")
    }

    func identifyUserWithCompanyTraits() {
        let traits: [String: Any] = [
            "email": "testuseriOS@example.com",
            "company": [
                "id": "company-1",
                "name": "RudderStack",
                "industry": "Software"
            ]
        ]

        analytics?.identify(userId: "rudderstack_ios_5", traits: traits)
        LoggerAnalytics.debug("Identified user with company traits")
    }

    // MARK: - Track Events

    func trackEventWithProperties() {
        let properties: [String: Any] = [
            "key_1": "value_1",
            "key_2": "value_2"
        ]

        analytics?.track(name: "New Track event", properties: properties)
        LoggerAnalytics.debug("Tracked event with properties")
    }

    func trackEventWithoutProperties() {
        analytics?.track(name: "New Track event")
        LoggerAnalytics.debug("Tracked event without properties")
    }

    /// Nested objects, arrays, and mixed primitive types, to exercise the property handling.
    func trackEventWithNestedProperties() {
        let properties: [String: Any] = [
            "stringValue": "value_1",
            "intValue": 42,
            "longValue": 9_876_543_210,
            "doubleValue": 12.34,
            "booleanValue": true,
            "nestedObject": [
                "nestedKey": "nestedValue",
                "nestedNumber": 7
            ],
            "nestedArray": ["first", "second"]
        ]

        analytics?.track(name: "Nested Track event", properties: properties)
        LoggerAnalytics.debug("Tracked event with nested properties")
    }

    // MARK: - Order Completed Events

    func orderCompletedWithoutProperties() {
        analytics?.track(name: "Order Completed")
        LoggerAnalytics.debug("Tracked Order Completed without properties")
    }

    func orderCompletedWithoutProducts() {
        let properties: [String: Any] = [
            "revenue": 123,
            "currency": "INR",
            "Key-1": "Value-1"
        ]

        analytics?.track(name: "Order Completed", properties: properties)
        LoggerAnalytics.debug("Tracked Order Completed without products")
    }

    func orderCompletedWithOrderId() {
        let properties: [String: Any] = [
            "revenue": 123,
            "currency": "INR",
            "Key-1": "Value-1",
            "order_id": "1234567890"
        ]

        analytics?.track(name: "Order Completed", properties: properties)
        LoggerAnalytics.debug("Tracked Order Completed with an order id")
    }

    func orderCompletedWithSingleProduct() {
        let properties: [String: Any] = [
            "products": [
                [
                    "product_id": "1001",
                    "quantity": 11,
                    "price": 100.11,
                    "Product-Key-1": "Product-Value-1"
                ]
            ],
            "revenue": 123,
            "currency": "INR",
            "Key-1": "Value-1"
        ]

        analytics?.track(name: "Order Completed", properties: properties)
        LoggerAnalytics.debug("Tracked Order Completed with a single product")
    }

    func orderCompletedWithSingleProductAndOrderId() {
        let properties: [String: Any] = [
            "products": [
                [
                    "product_id": "1001",
                    "quantity": 11,
                    "price": 100.11,
                    "Product-Key-1": "Product-Value-1"
                ]
            ],
            "revenue": 123,
            "currency": "INR",
            "Key-1": "Value-1",
            "order_id": "1234567890"
        ]

        analytics?.track(name: "Order Completed", properties: properties)
        LoggerAnalytics.debug("Tracked Order Completed with a single product and an order id")
    }

    /// A revenue that is not a number. The integration drops the CleverTap amount and logs a
    /// warning. A zero fallback would record a real zero-value purchase against the user.
    func orderCompletedWithNonNumericRevenue() {
        let properties: [String: Any] = [
            "revenue": "not-a-number",
            "currency": "INR",
            "order_id": "invalid-revenue-1"
        ]

        analytics?.track(name: "Order Completed", properties: properties)
        LoggerAnalytics.debug("Tracked Order Completed with a non numeric revenue")
    }

    func orderCompletedWithMultipleProducts() {
        let properties: [String: Any] = [
            "products": [
                [
                    "product_id": "1001",
                    "quantity": 11,
                    "price": 100.11,
                    "Product-Key-1": "Product-Value-1"
                ],
                [
                    "product_id": "1002",
                    "quantity": 5,
                    "price": 89.11,
                    "Product-Key-2": "Product-Value-2"
                ]
            ],
            "revenue": 123,
            "currency": "INR",
            "Key-1": "Value-1",
            "order_id": "1234567890"
        ]

        analytics?.track(name: "Order Completed", properties: properties)
        LoggerAnalytics.debug("Tracked Order Completed with multiple products")
    }

    // MARK: - Screen Events

    func screenEventWithProperties() {
        let properties: [String: Any] = [
            "key_1": "value_1",
            "key_2": "value_2"
        ]

        analytics?.screen(screenName: "Home", properties: properties)
        LoggerAnalytics.debug("Screen event sent with properties")
    }

    func screenEventWithoutProperties() {
        analytics?.screen(screenName: "Home")
        LoggerAnalytics.debug("Screen event sent without properties")
    }

    // MARK: - Reset

    func resetUser() {
        analytics?.reset()
        LoggerAnalytics.debug("Reset user state")
    }

    // MARK: - Flush

    func flush() {
        analytics?.flush()
        LoggerAnalytics.debug("Flushed analytics queue")
    }
}
