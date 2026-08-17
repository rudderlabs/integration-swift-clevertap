//
//  CleverTapTestUtils.swift
//  RudderIntegrationCleverTapTests
//
//  Mock adapter and test data for the CleverTap integration tests.
//

import Foundation
import RudderStackAnalytics
@testable import RudderIntegrationCleverTap

// MARK: - MockCleverTapAdapter

/**
 A `CleverTapAdapter` that records every call instead of forwarding it to the CleverTap SDK.
 */
class MockCleverTapAdapter: CleverTapAdapter {

    // MARK: - Recorded Calls

    var setCredentialsCalls: [(accountId: String, token: String, region: String?)] = []
    var notifyApplicationLaunchedCallCount = 0
    var setDebugLevelCalls: [LogLevel] = []
    var onUserLoginCalls: [[String: Any]] = []
    var recordEventCalls: [(event: String, properties: [String: Any]?)] = []
    var recordChargedEventCalls: [(details: [String: Any], items: [[String: Any]])] = []

    /// When `true`, the adapter behaves like a CleverTap SDK that returns no instance.
    var returnsNoInstance = false

    private var isInitialized = false

    // MARK: - CleverTapAdapter

    func setCredentials(accountId: String, token: String) {
        setCredentialsCalls.append((accountId: accountId, token: token, region: nil))
    }

    func setCredentials(accountId: String, token: String, region: String) {
        setCredentialsCalls.append((accountId: accountId, token: token, region: region))
    }

    func notifyApplicationLaunched() {
        notifyApplicationLaunchedCallCount += 1
        isInitialized = !returnsNoInstance
    }

    func setDebugLevel(_ logLevel: LogLevel) {
        setDebugLevelCalls.append(logLevel)
    }

    func onUserLogin(profile: [String: Any]) {
        onUserLoginCalls.append(profile)
    }

    func recordEvent(_ event: String) {
        recordEventCalls.append((event: event, properties: nil))
    }

    func recordEvent(_ event: String, properties: [String: Any]) {
        recordEventCalls.append((event: event, properties: properties))
    }

    func recordChargedEvent(details: [String: Any], items: [[String: Any]]) {
        recordChargedEventCalls.append((details: details, items: items))
    }

    func getDestinationInstance() -> Any? {
        return isInitialized ? "MockCleverTapInstance" : nil
    }

    // MARK: - Helper

    func reset() {
        isInitialized = false
        returnsNoInstance = false
        setCredentialsCalls.removeAll()
        notifyApplicationLaunchedCallCount = 0
        setDebugLevelCalls.removeAll()
        onUserLoginCalls.removeAll()
        recordEventCalls.removeAll()
        recordChargedEventCalls.removeAll()
    }
}

// MARK: - CleverTapTestData

/**
 The destination configurations and the events that the CleverTap integration tests use.
 */
struct CleverTapTestData {

    static let accountId = "test-account-id-123"
    static let accountToken = "test-account-token-456"
    static let region = "eu1"

    static var validConfig: [String: Any] {
        [
            "accountId": accountId,
            "accountToken": accountToken,
            "region": region
        ]
    }

    static var configWithoutRegion: [String: Any] {
        [
            "accountId": accountId,
            "accountToken": accountToken,
            "region": "none"
        ]
    }

    static var configWithoutAccountId: [String: Any] {
        [
            "accountToken": accountToken,
            "region": region
        ]
    }

    static var configWithEmptyAccountToken: [String: Any] {
        [
            "accountId": accountId,
            "accountToken": "",
            "region": region
        ]
    }

    static var orderCompletedProperties: [String: Any] {
        [
            "order_id": "order-123",
            "revenue": 99.99,
            "currency": "USD",
            "coupon": "SAVE10",
            "nested": ["dropped": "value"],
            "products": [
                ["product_id": "product-1", "name": "Shoes", "price": 49.99],
                ["product_id": "product-2", "name": "Socks", "price": 50.0]
            ]
        ]
    }
}

// MARK: - Event Creation Helpers

extension CleverTapTestData {

    static func createIdentifyEvent(
        userId: String? = "test_user_123",
        traits: [String: Any]? = nil
    ) -> IdentifyEvent {
        var event = IdentifyEvent()
        event.userId = userId

        if let traits {
            let context: [String: Any] = ["traits": traits]
            event.context = context.codableWrapped
        }

        return event
    }

    static func createTrackEvent(
        name: String,
        properties: [String: Any]? = nil
    ) -> TrackEvent {
        return TrackEvent(event: name, properties: properties)
    }

    static func createScreenEvent(
        name: String,
        properties: [String: Any]? = nil
    ) -> ScreenEvent {
        return ScreenEvent(screenName: name, properties: properties)
    }
}
