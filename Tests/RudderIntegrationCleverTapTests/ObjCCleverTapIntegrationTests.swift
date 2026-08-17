//
//  ObjCCleverTapIntegrationTests.swift
//  RudderIntegrationCleverTapTests
//

import Testing
import Foundation
import RudderStackAnalytics
@testable import RudderIntegrationCleverTap

@Suite
struct ObjCCleverTapIntegrationTests {

    // MARK: - Helper Methods

    private func makeAnalytics() -> Analytics {
        let config = Configuration(
            writeKey: "test-write-key",
            dataPlaneUrl: "https://test.rudderstack.com"
        )
        return Analytics(configuration: config)
    }

    // MARK: - Setup Tests

    @Test("given a new wrapper, when setup is not called, then the wrapped integration has no analytics")
    func testWrappedIntegrationStartsWithoutAnalytics() {
        let wrapper = ObjCCleverTapIntegration()

        #expect(wrapper.cleverTapIntegration.analytics == nil)
    }

    @Test("given an analytics client, when setup is called, then the wrapped integration receives it")
    func testSetupPropagatesAnalytics() throws {
        let analytics = makeAnalytics()
        let wrapper = ObjCCleverTapIntegration()

        wrapper.setup(ObjCAnalytics(analytics: analytics))

        let propagated = try #require(wrapper.cleverTapIntegration.analytics)
        #expect(propagated === analytics)
    }
}
