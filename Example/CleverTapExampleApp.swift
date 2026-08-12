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
        let traits: [String: Any] = [
            "email": "test.swift@integration-test.com",
            "name": "Test User",
            "phone": "0123456789",
            "gender": "female",
            "birthday": "1990-05-17",
            "plan": "enterprise"
        ]

        analytics?.identify(userId: "test_user_ios_1", traits: traits)
        LoggerAnalytics.debug("Identified user with traits")
    }

    func identifyUserWithNestedTraits() {
        let traits: [String: Any] = [
            "email": "test.swift@integration-test.com",
            "address": [
                "city": "Bengaluru",
                "country": "India"
            ],
            "company": [
                "id": "company-1",
                "name": "RudderStack",
                "industry": "Software"
            ]
        ]

        analytics?.identify(userId: "test_user_ios_2", traits: traits)
        LoggerAnalytics.debug("Identified user with nested traits")
    }

    // MARK: - Track Events

    func trackEventWithProperties() {
        let properties: [String: Any] = [
            "key_1": "value_1",
            "key_2": "value_2"
        ]

        analytics?.track(name: "Custom Event", properties: properties)
        LoggerAnalytics.debug("Tracked custom event with properties")
    }

    func trackEventWithoutProperties() {
        analytics?.track(name: "Simple Event")
        LoggerAnalytics.debug("Tracked simple event")
    }

    func trackOrderCompleted() {
        let properties: [String: Any] = [
            "order_id": "order-123",
            "revenue": 99.99,
            "currency": "USD",
            "products": [
                ["product_id": "product-1", "name": "Shoes", "price": 49.99],
                ["product_id": "product-2", "name": "Socks", "price": 50.00]
            ]
        ]

        analytics?.track(name: "Order Completed", properties: properties)
        LoggerAnalytics.debug("Tracked the Order Completed event")
    }

    // MARK: - Screen Events

    func screenEvent() {
        let properties: [String: Any] = [
            "key_1": "value_1"
        ]

        analytics?.screen(screenName: "Home Screen", properties: properties)
        LoggerAnalytics.debug("Screen event sent")
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
