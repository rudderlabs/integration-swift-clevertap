//
//  CleverTapIntegration.swift
//  RudderIntegrationCleverTap
//
//  Swift integration for the CleverTap destination.
//

import Foundation
import RudderStackAnalytics

// MARK: - CleverTapIntegration

/**
 The RudderStack device mode integration for CleverTap.

 Add the integration to the analytics client to send events to the CleverTap iOS SDK:
 ```swift
 let analytics = Analytics(configuration: configuration)
 analytics.add(plugin: CleverTapIntegration())
 ```
 */
public class CleverTapIntegration: IntegrationPlugin, StandardIntegration {

    // MARK: - Required Protocol Properties

    /// The plugin type. A destination integration is always terminal.
    public var pluginType: PluginType = .terminal

    /// The analytics instance that owns this plugin.
    public var analytics: Analytics?

    /// The destination name in the RudderStack dashboard.
    public var key: String = "CleverTap"

    // MARK: - Private Properties

    private let cleverTapAdapter: CleverTapAdapter

    // MARK: - Initialization

    /**
     Creates a CleverTap integration that uses the CleverTap iOS SDK.
     */
    public init() {
        self.cleverTapAdapter = DefaultCleverTapAdapter()
    }

    /**
     Creates a CleverTap integration with the given adapter. Unit tests use this initializer to
     inject a mock adapter.

     - Parameter cleverTapAdapter: The adapter that receives the CleverTap SDK calls.
     */
    internal init(cleverTapAdapter: CleverTapAdapter) {
        self.cleverTapAdapter = cleverTapAdapter
    }

    // MARK: - Required Protocol Methods

    /**
     Initializes the CleverTap SDK from the destination configuration.

     - Parameter destinationConfig: The destination configuration from the RudderStack dashboard.
     - Throws: `CleverTapIntegrationError.missingCredentials` when the account identifier or the
       account token is absent.
     */
    public func create(destinationConfig: [String: Any]) throws {
        guard cleverTapAdapter.getDestinationInstance() == nil else {
            logger.debug(log: "CleverTapIntegration: The CleverTap SDK is already initialized.")
            return
        }

        guard let accountId = destinationConfig[CleverTapConstants.accountId] as? String, !accountId.isEmpty,
              let accountToken = destinationConfig[CleverTapConstants.accountToken] as? String, !accountToken.isEmpty else {
            logger.error(log: "CleverTapIntegration: The accountId or the accountToken is missing or empty.", error: nil)
            throw CleverTapIntegrationError.missingCredentials
        }

        let region = destinationConfig[CleverTapConstants.region] as? String
        if let region, !region.isEmpty, region != CleverTapConstants.noRegion {
            cleverTapAdapter.setCredentials(accountId: accountId, token: accountToken, region: region)
        } else {
            cleverTapAdapter.setCredentials(accountId: accountId, token: accountToken)
        }

        cleverTapAdapter.notifyApplicationLaunched()
        cleverTapAdapter.setDebugLevel(LoggerAnalytics.logLevel)

        logger.debug(log: "CleverTapIntegration: The CleverTap SDK is initialized.")
    }

    /**
     Returns the CleverTap SDK instance.

     - Returns: The CleverTap instance, or `nil` when the SDK is not initialized.
     */
    public func getDestinationInstance() -> Any? {
        return cleverTapAdapter.getDestinationInstance()
    }

    // MARK: - Event Methods

    /**
     Sends an identify event to CleverTap as a user login.

     - Parameter payload: The identify event.
     */
    public func identify(payload: IdentifyEvent) {
        let traits = payload.context?.rawDictionary[Constants.traitsKey] as? [String: Any] ?? [:]
        let profile = CleverTapUtils.buildProfile(userId: payload.userId, traits: traits)

        cleverTapAdapter.onUserLogin(profile: profile)
        logger.debug(log: "CleverTapIntegration: Recorded a user login.")
    }

    /**
     Sends a track event to CleverTap. CleverTap receives the `Order Completed` event as a charged
     event, and every other event as a custom event.

     - Parameter payload: The track event.
     */
    public func track(payload: TrackEvent) {
        let eventName = payload.event
        guard !eventName.isEmpty else {
            logger.debug(log: "CleverTapIntegration: The event name is empty. Dropped the track event.")
            return
        }

        if eventName == CleverTapConstants.orderCompleted {
            handleOrderCompletedEvent(payload: payload)
            return
        }

        recordEvent(named: eventName, properties: payload.properties?.dictionary?.rawDictionary)
    }

    /**
     Sends a screen event to CleverTap as a custom event.

     - Parameter payload: The screen event.
     */
    public func screen(payload: ScreenEvent) {
        let screenName = payload.event
        guard !screenName.isEmpty else {
            logger.debug(log: "CleverTapIntegration: The screen name is empty. Dropped the screen event.")
            return
        }

        let eventName = CleverTapConstants.screenEventPrefix + screenName
        recordEvent(named: eventName, properties: payload.properties?.dictionary?.rawDictionary)
    }

    /**
     Resets the integration. CleverTap keeps the user profile until the next user login, so the
     method has no effect on the CleverTap SDK.
     */
    public func reset() {
        logger.debug(log: "CleverTapIntegration: Inside reset.")
    }

    // MARK: - Private Helpers

    /**
     Sends the `Order Completed` event to CleverTap as a charged event.

     - Parameter payload: The track event.
     */
    private func handleOrderCompletedEvent(payload: TrackEvent) {
        guard let properties = payload.properties?.dictionary?.rawDictionary else {
            logger.debug(log: "CleverTapIntegration: The properties are absent. Dropped the charged event.")
            return
        }

        let chargedEvent = CleverTapUtils.buildChargedEvent(from: properties)
        if let invalidRevenue = chargedEvent.invalidRevenue {
            logger.warn(log: "CleverTapIntegration: Cannot read the revenue '\(invalidRevenue)' as a number. CleverTap does not receive the amount.")
        }

        cleverTapAdapter.recordChargedEvent(details: chargedEvent.details, items: chargedEvent.items)
        logger.debug(log: "CleverTapIntegration: Recorded a charged event.")
    }

    /**
     Records an event with or without properties.

     - Parameters:
        - name: The event name.
        - properties: The event properties.
     */
    private func recordEvent(named name: String, properties: [String: Any]?) {
        if let properties {
            cleverTapAdapter.recordEvent(name, properties: properties)
        } else {
            cleverTapAdapter.recordEvent(name)
        }
        logger.debug(log: "CleverTapIntegration: Recorded the event '\(name)'.")
    }
}

// MARK: - Constants

private enum Constants {
    static let traitsKey = "traits"
}

// MARK: - CleverTapIntegrationError

/**
 The errors that the CleverTap integration reports from `create(destinationConfig:)`.
 */
enum CleverTapIntegrationError: LocalizedError {

    /// The account identifier or the account token is absent.
    case missingCredentials

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Missing accountId or accountToken"
        }
    }
}
