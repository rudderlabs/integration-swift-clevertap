//
//  ObjCCleverTapIntegration.swift
//  RudderIntegrationCleverTap
//
//  Objective-C wrapper for the CleverTap integration.
//

import Foundation
import RudderStackAnalytics

// MARK: - ObjCCleverTapIntegration

/**
 An Objective-C compatible wrapper for the CleverTap integration.

 This class gives Objective-C apps an interface to the CleverTap device mode integration.

 ## Usage in Objective-C:
 ```objc
 RSSConfigurationBuilder *builder = [[RSSConfigurationBuilder alloc] initWithWriteKey:@"<WriteKey>"
                                                                        dataPlaneUrl:@"<DataPlaneUrl>"];
 RSSAnalytics *analytics = [[RSSAnalytics alloc] initWithConfiguration:[builder build]];

 RSSCleverTapIntegration *cleverTapIntegration = [[RSSCleverTapIntegration alloc] init];
 [analytics addPlugin:cleverTapIntegration];
 ```
 */
@objc(RSSCleverTapIntegration)
public class ObjCCleverTapIntegration: NSObject, ObjCIntegrationPlugin, ObjCStandardIntegration {

    // MARK: - ObjCPlugin Properties

    public var pluginType: PluginType {
        get { cleverTapIntegration.pluginType }
        set { cleverTapIntegration.pluginType = newValue }
    }

    // MARK: - ObjCIntegrationPlugin Properties

    public var key: String {
        get { cleverTapIntegration.key }
        set { cleverTapIntegration.key = newValue }
    }

    // MARK: - Private Properties

    private let cleverTapIntegration: CleverTapIntegration

    // MARK: - Initializers

    /**
     Initializes a new CleverTap integration instance.

     Use this initializer to create a CleverTap integration that you add to the analytics client.
     */
    @objc
    public override init() {
        self.cleverTapIntegration = CleverTapIntegration()
        super.init()
    }

    // MARK: - ObjCIntegrationPlugin Methods

    /**
     Returns the CleverTap SDK instance.

     - Returns: The CleverTap instance, or nil when the SDK is not initialized.
     */
    @objc
    public func getDestinationInstance() -> Any? {
        return cleverTapIntegration.getDestinationInstance()
    }

    /**
     Initializes the CleverTap SDK with the given destination configuration.

     - Parameters:
        - destinationConfig: The configuration dictionary from the RudderStack dashboard.
        - errorPointer: A pointer to an NSError that receives the failure reason.
     - Returns: `true` when the initialization succeeded, `false` otherwise.
     */
    @objc
    public func createWithDestinationConfig(_ destinationConfig: [String: Any], error errorPointer: NSErrorPointer) -> Bool {
        do {
            try cleverTapIntegration.create(destinationConfig: destinationConfig)
            return true
        } catch let err as NSError {
            errorPointer?.pointee = err
            return false
        } catch {
            errorPointer?.pointee = NSError(
                domain: "com.rudderstack.CleverTapIntegration",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]
            )
            return false
        }
    }

    // MARK: - ObjCEventPlugin Methods

    /**
     Forwards an identify event to the CleverTap integration.

     - Parameter payload: The Objective-C identify event payload.
     */
    @objc
    public func identify(_ payload: ObjCIdentifyEvent) {
        var identifyEvent = IdentifyEvent(options: payload.options)
        identifyEvent.anonymousId = payload.anonymousId
        identifyEvent.userId = payload.userId
        identifyEvent.context = payload.context?.codableWrapped

        cleverTapIntegration.identify(payload: identifyEvent)
    }

    /**
     Forwards a track event to the CleverTap integration.

     - Parameter payload: The Objective-C track event payload.
     */
    @objc
    public func track(_ payload: ObjCTrackEvent) {
        var trackEvent = TrackEvent(
            event: payload.eventName,
            properties: payload.properties,
            options: payload.options
        )
        trackEvent.anonymousId = payload.anonymousId
        trackEvent.userId = payload.userId

        cleverTapIntegration.track(payload: trackEvent)
    }

    /**
     Forwards a screen event to the CleverTap integration.

     - Parameter payload: The Objective-C screen event payload.
     */
    @objc
    public func screen(_ payload: ObjCScreenEvent) {
        var screenEvent = ScreenEvent(
            screenName: payload.screenName,
            category: payload.category,
            properties: payload.properties,
            options: payload.options
        )
        screenEvent.anonymousId = payload.anonymousId
        screenEvent.userId = payload.userId

        cleverTapIntegration.screen(payload: screenEvent)
    }

    /**
     Forwards a reset call to the CleverTap integration.
     */
    @objc
    public func reset() {
        cleverTapIntegration.reset()
    }
}
