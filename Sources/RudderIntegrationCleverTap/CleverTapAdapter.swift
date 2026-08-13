//
//  CleverTapAdapter.swift
//  RudderIntegrationCleverTap
//
//  Abstraction over the CleverTap iOS SDK.
//

import Foundation
import CleverTapSDK
import RudderStackAnalytics

// MARK: - CleverTapAdapter

/**
 An abstraction over the CleverTap iOS SDK.

 Every method is a thin wrapper around a single CleverTap SDK call. The protocol keeps the
 integration testable, because a mock adapter can replace the real SDK in unit tests.
 */
protocol CleverTapAdapter {

    /**
     Sets the CleverTap credentials without a region.

     - Parameters:
        - accountId: The CleverTap account identifier.
        - token: The CleverTap account token.
     */
    func setCredentials(accountId: String, token: String)

    /**
     Sets the CleverTap credentials for a specific region.

     - Parameters:
        - accountId: The CleverTap account identifier.
        - token: The CleverTap account token.
        - region: The CleverTap account region.
     */
    func setCredentials(accountId: String, token: String, region: String)

    /**
     Notifies the CleverTap SDK that the application launched.
     */
    func notifyApplicationLaunched()

    /**
     Sets the CleverTap debug level from the RudderStack log level.

     - Parameter logLevel: The RudderStack log level.
     */
    func setDebugLevel(_ logLevel: LogLevel)

    /**
     Records a user login with the given profile.

     - Parameter profile: The CleverTap profile attributes.
     */
    func onUserLogin(profile: [String: Any])

    /**
     Records an event without properties.

     - Parameter event: The event name.
     */
    func recordEvent(_ event: String)

    /**
     Records an event with properties.

     - Parameters:
        - event: The event name.
        - properties: The event properties.
     */
    func recordEvent(_ event: String, properties: [String: Any])

    /**
     Records a charged event.

     - Parameters:
        - details: The charge details.
        - items: The purchased items.
     */
    func recordChargedEvent(details: [String: Any], items: [[String: Any]])

    /**
     Returns the CleverTap SDK instance.

     - Returns: The CleverTap instance, or `nil` when the SDK is not initialized.
     */
    func getDestinationInstance() -> Any?
}

// MARK: - DefaultCleverTapAdapter

/**
 The default `CleverTapAdapter`. It forwards every call to the CleverTap iOS SDK.
 */
class DefaultCleverTapAdapter: CleverTapAdapter {

    private var cleverTap: CleverTap?

    init() { /* Default initializer */ }

    func setCredentials(accountId: String, token: String) {
        CleverTap.setCredentialsWithAccountID(accountId, andToken: token)
    }

    func setCredentials(accountId: String, token: String, region: String) {
        CleverTap.setCredentialsWithAccountID(accountId, token: token, region: region)
    }

    func notifyApplicationLaunched() {
        // The CleverTap SDK reads UIScreen, UIDevice, and the application state here, and it can
        // show an in-app message. All of that needs the main thread. The RudderStack SDK calls
        // `create` from a background queue after it fetches the source configuration.
        MainThread.run {
            let instance = CleverTap.sharedInstance()
            instance?.notifyApplicationLaunched(withOptions: nil)
            self.cleverTap = instance
        }
    }

    func setDebugLevel(_ logLevel: LogLevel) {
        CleverTap.setDebugLevel(Int32(cleverTapLogLevel(from: logLevel).rawValue))
    }

    func onUserLogin(profile: [String: Any]) {
        cleverTap?.onUserLogin(profile)
    }

    func recordEvent(_ event: String) {
        cleverTap?.recordEvent(event)
    }

    func recordEvent(_ event: String, properties: [String: Any]) {
        cleverTap?.recordEvent(event, withProps: properties)
    }

    func recordChargedEvent(details: [String: Any], items: [[String: Any]]) {
        cleverTap?.recordChargedEvent(withDetails: details, andItems: items)
    }

    func getDestinationInstance() -> Any? {
        return cleverTap
    }

    /**
     Maps the RudderStack log level to the CleverTap log level.

     - Parameter logLevel: The RudderStack log level.
     - Returns: The matching CleverTap log level.
     */
    private func cleverTapLogLevel(from logLevel: LogLevel) -> CleverTapLogLevel {
        switch logLevel {
        case .none:
            return .off
        case .debug, .verbose:
            return .debug
        default:
            return .info
        }
    }
}
