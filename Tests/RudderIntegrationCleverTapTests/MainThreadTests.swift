//
//  MainThreadTests.swift
//  RudderIntegrationCleverTapTests
//

import Testing
import Foundation
@testable import RudderIntegrationCleverTap

@Suite
struct MainThreadTests {

    @Test("given a background thread, when run is called, then the work runs on the main thread")
    func testRunFromBackgroundThread() async {
        // The test awaits instead of blocking, so the main thread stays free to serve the hop.
        let result: (startedOffMainThread: Bool, ranOnMainThread: Bool) = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .default).async {
                let startedOffMainThread = !Thread.isMainThread
                var ranOnMainThread = false

                MainThread.run { ranOnMainThread = Thread.isMainThread }

                continuation.resume(returning: (startedOffMainThread, ranOnMainThread))
            }
        }

        #expect(result.startedOffMainThread)
        #expect(result.ranOnMainThread)
    }

    @Test("given the main thread, when run is called, then the work runs without a deadlock")
    @MainActor
    func testRunFromMainThread() {
        #expect(Thread.isMainThread)
        var ranOnMainThread = false

        MainThread.run { ranOnMainThread = Thread.isMainThread }

        #expect(ranOnMainThread)
    }
}
