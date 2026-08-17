//
//  MainThread.swift
//  RudderIntegrationCleverTap
//

import Foundation

// MARK: - MainThread

/**
 Runs work on the main thread.
 */
enum MainThread {

    /**
     Runs the work on the main thread.

     The method runs the work directly when the caller is already on the main thread. The
     RudderStack SDK calls `create` on the caller thread when it holds a cached source
     configuration, so an unguarded `DispatchQueue.main.sync` would deadlock.

     - Parameter work: The work that needs the main thread.
     */
    static func run(_ work: () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }
}
