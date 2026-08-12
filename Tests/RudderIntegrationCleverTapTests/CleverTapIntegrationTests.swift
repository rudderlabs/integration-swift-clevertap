//
//  CleverTapIntegrationTests.swift
//  RudderIntegrationCleverTapTests
//

import Testing
import Foundation
import RudderStackAnalytics
@testable import RudderIntegrationCleverTap

@Suite(.serialized)
class CleverTapIntegrationTests {

    // MARK: - Test Properties

    private var mockAdapter: MockCleverTapAdapter!
    private var integration: CleverTapIntegration!
    private var mockAnalytics: Analytics!

    // MARK: - Setup and Teardown

    init() {
        self.mockAdapter = MockCleverTapAdapter()
        self.integration = CleverTapIntegration(cleverTapAdapter: mockAdapter)

        let config = Configuration(
            writeKey: "test-write-key",
            dataPlaneUrl: "https://test.rudderstack.com"
        )
        self.mockAnalytics = Analytics(configuration: config)
        self.integration.analytics = mockAnalytics
    }

    deinit {
        self.mockAdapter = nil
        self.integration = nil
        self.mockAnalytics = nil
    }

    // MARK: - Helper Methods

    private func setupWithDefaultConfig() throws {
        try integration.create(destinationConfig: CleverTapTestData.validConfig)
    }

    // MARK: - Create Tests

    @Test("given a config with a region, when create is called, then the region credentials are set")
    func testCreateWithRegion() throws {
        try setupWithDefaultConfig()

        #expect(mockAdapter.setCredentialsCalls.count == 1)
        #expect(mockAdapter.setCredentialsCalls[0].accountId == CleverTapTestData.accountId)
        #expect(mockAdapter.setCredentialsCalls[0].token == CleverTapTestData.accountToken)
        #expect(mockAdapter.setCredentialsCalls[0].region == CleverTapTestData.region)
        #expect(mockAdapter.notifyApplicationLaunchedCallCount == 1)
        #expect(mockAdapter.setDebugLevelCalls.count == 1)
    }

    @Test("given a config with the region none, when create is called, then no region is set")
    func testCreateWithoutRegion() throws {
        try integration.create(destinationConfig: CleverTapTestData.configWithoutRegion)

        #expect(mockAdapter.setCredentialsCalls.count == 1)
        #expect(mockAdapter.setCredentialsCalls[0].region == nil)
        #expect(mockAdapter.notifyApplicationLaunchedCallCount == 1)
    }

    @Test("given a config without a region key, when create is called, then no region is set")
    func testCreateWithMissingRegionKey() throws {
        try integration.create(destinationConfig: [
            "accountId": CleverTapTestData.accountId,
            "accountToken": CleverTapTestData.accountToken
        ])

        #expect(mockAdapter.setCredentialsCalls.count == 1)
        #expect(mockAdapter.setCredentialsCalls[0].region == nil)
    }

    @Test("given a config without an accountId, when create is called, then it throws")
    func testCreateWithoutAccountId() {
        #expect(throws: CleverTapIntegrationError.missingCredentials) {
            try integration.create(destinationConfig: CleverTapTestData.configWithoutAccountId)
        }
        #expect(mockAdapter.setCredentialsCalls.isEmpty)
        #expect(mockAdapter.notifyApplicationLaunchedCallCount == 0)
    }

    @Test("given a config with an empty accountToken, when create is called, then it throws")
    func testCreateWithEmptyAccountToken() {
        #expect(throws: CleverTapIntegrationError.missingCredentials) {
            try integration.create(destinationConfig: CleverTapTestData.configWithEmptyAccountToken)
        }
        #expect(mockAdapter.setCredentialsCalls.isEmpty)
    }

    @Test("given an initialized integration, when create is called again, then the SDK is not initialized twice")
    func testCreateIsIdempotent() throws {
        try setupWithDefaultConfig()
        try setupWithDefaultConfig()

        #expect(mockAdapter.setCredentialsCalls.count == 1)
        #expect(mockAdapter.notifyApplicationLaunchedCallCount == 1)
    }

    @Test("given an initialized integration, when getDestinationInstance is called, then it returns the instance")
    func testGetDestinationInstanceWhenInitialized() throws {
        try setupWithDefaultConfig()

        #expect(integration.getDestinationInstance() != nil)
    }

    @Test("given an uninitialized integration, when getDestinationInstance is called, then it returns nil")
    func testGetDestinationInstanceWhenNotInitialized() {
        #expect(integration.getDestinationInstance() == nil)
    }

    @Test("given a new integration, when it is created, then the key and the plugin type are correct")
    func testIntegrationMetadata() {
        #expect(integration.key == "CleverTap")
        #expect(integration.pluginType == .terminal)
    }

    // MARK: - Identify Tests

    @Test("given an identify event with a userId, when identify is called, then the Identity is set")
    func testIdentifyWithUserId() throws {
        try setupWithDefaultConfig()
        let event = CleverTapTestData.createIdentifyEvent(userId: "test_user_123")

        integration.identify(payload: event)

        #expect(mockAdapter.onUserLoginCalls.count == 1)
        #expect(mockAdapter.onUserLoginCalls[0]["Identity"] as? String == "test_user_123")
    }

    @Test("given an identify event without a userId, when identify is called, then no Identity is set")
    func testIdentifyWithoutUserId() throws {
        try setupWithDefaultConfig()
        let event = CleverTapTestData.createIdentifyEvent(userId: nil, traits: ["email": "test@example.com"])

        integration.identify(payload: event)

        #expect(mockAdapter.onUserLoginCalls.count == 1)
        #expect(mockAdapter.onUserLoginCalls[0]["Identity"] == nil)
        #expect(mockAdapter.onUserLoginCalls[0]["Email"] as? String == "test@example.com")
    }

    @Test("given an identify event with standard traits, when identify is called, then the traits are mapped")
    func testIdentifyWithStandardTraits() throws {
        try setupWithDefaultConfig()
        let event = CleverTapTestData.createIdentifyEvent(traits: [
            "email": "test@example.com",
            "name": "Test User",
            "phone": 1234567890,
            "gender": "female"
        ])

        integration.identify(payload: event)

        let profile = try #require(mockAdapter.onUserLoginCalls.first)
        #expect(profile["Email"] as? String == "test@example.com")
        #expect(profile["Name"] as? String == "Test User")
        #expect(profile["Phone"] as? String == "1234567890")
        #expect(profile["Gender"] as? String == "F")
    }

    @Test("given an identify event with custom traits, when identify is called, then the traits are forwarded")
    func testIdentifyWithCustomTraits() throws {
        try setupWithDefaultConfig()
        let event = CleverTapTestData.createIdentifyEvent(traits: [
            "plan": "enterprise",
            "credits": 42,
            "unsupported": ["nested": "value"]
        ])

        integration.identify(payload: event)

        let profile = try #require(mockAdapter.onUserLoginCalls.first)
        #expect(profile["plan"] as? String == "enterprise")
        #expect(profile["credits"] as? Int == 42)
        #expect(profile["unsupported"] == nil)
    }

    // MARK: - Track Tests

    @Test("given a track event without properties, when track is called, then the event is recorded")
    func testTrackWithoutProperties() throws {
        try setupWithDefaultConfig()
        let event = CleverTapTestData.createTrackEvent(name: "Test Event")

        integration.track(payload: event)

        #expect(mockAdapter.recordEventCalls.count == 1)
        #expect(mockAdapter.recordEventCalls[0].event == "Test Event")
        #expect(mockAdapter.recordEventCalls[0].properties == nil)
    }

    @Test("given a track event with properties, when track is called, then the properties are forwarded")
    func testTrackWithProperties() throws {
        try setupWithDefaultConfig()
        let event = CleverTapTestData.createTrackEvent(name: "Test Event", properties: ["key": "value"])

        integration.track(payload: event)

        #expect(mockAdapter.recordEventCalls.count == 1)
        #expect(mockAdapter.recordEventCalls[0].event == "Test Event")
        #expect(mockAdapter.recordEventCalls[0].properties?["key"] as? String == "value")
    }

    @Test("given a track event with an empty name, when track is called, then the event is dropped")
    func testTrackWithEmptyName() throws {
        try setupWithDefaultConfig()
        let event = CleverTapTestData.createTrackEvent(name: "")

        integration.track(payload: event)

        #expect(mockAdapter.recordEventCalls.isEmpty)
    }

    @Test("given an Order Completed event, when track is called, then a charged event is recorded")
    func testTrackOrderCompleted() throws {
        try setupWithDefaultConfig()
        let event = CleverTapTestData.createTrackEvent(
            name: "Order Completed",
            properties: CleverTapTestData.orderCompletedProperties
        )

        integration.track(payload: event)

        #expect(mockAdapter.recordEventCalls.isEmpty)
        #expect(mockAdapter.recordChargedEventCalls.count == 1)

        let charged = try #require(mockAdapter.recordChargedEventCalls.first)
        #expect(charged.details["Charged ID"] as? String == "order-123")
        #expect(charged.details["Amount"] as? Double == 99.99)
        #expect(charged.details["currency"] as? String == "USD")
        #expect(charged.details["nested"] == nil)
        #expect(charged.details["products"] == nil)
        #expect(charged.items.count == 2)
        #expect(charged.items[0]["id"] as? String == "product-1")
        #expect(charged.items[0]["product_id"] == nil)
    }

    @Test("given an Order Completed event without properties, when track is called, then nothing is recorded")
    func testTrackOrderCompletedWithoutProperties() throws {
        try setupWithDefaultConfig()
        let event = CleverTapTestData.createTrackEvent(name: "Order Completed")

        integration.track(payload: event)

        #expect(mockAdapter.recordChargedEventCalls.isEmpty)
        #expect(mockAdapter.recordEventCalls.isEmpty)
    }

    // MARK: - Screen Tests

    @Test("given a screen event without properties, when screen is called, then a prefixed event is recorded")
    func testScreenWithoutProperties() throws {
        try setupWithDefaultConfig()
        let event = CleverTapTestData.createScreenEvent(name: "Home")

        integration.screen(payload: event)

        #expect(mockAdapter.recordEventCalls.count == 1)
        #expect(mockAdapter.recordEventCalls[0].event == "Screen Viewed: Home")
        // The SDK adds the screen name to the properties of every screen event.
        #expect(mockAdapter.recordEventCalls[0].properties?["name"] as? String == "Home")
    }

    @Test("given a screen event with properties, when screen is called, then the properties are forwarded")
    func testScreenWithProperties() throws {
        try setupWithDefaultConfig()
        let event = CleverTapTestData.createScreenEvent(name: "Home", properties: ["section": "main"])

        integration.screen(payload: event)

        #expect(mockAdapter.recordEventCalls.count == 1)
        #expect(mockAdapter.recordEventCalls[0].event == "Screen Viewed: Home")
        #expect(mockAdapter.recordEventCalls[0].properties?["section"] as? String == "main")
    }

    @Test("given a screen event with an empty name, when screen is called, then the event is dropped")
    func testScreenWithEmptyName() throws {
        try setupWithDefaultConfig()
        let event = CleverTapTestData.createScreenEvent(name: "")

        integration.screen(payload: event)

        #expect(mockAdapter.recordEventCalls.isEmpty)
    }

    // MARK: - Reset Tests

    @Test("given an initialized integration, when reset is called, then no CleverTap call is made")
    func testReset() throws {
        try setupWithDefaultConfig()

        integration.reset()

        #expect(mockAdapter.onUserLoginCalls.isEmpty)
        #expect(mockAdapter.recordEventCalls.isEmpty)
        #expect(mockAdapter.recordChargedEventCalls.isEmpty)
    }
}
