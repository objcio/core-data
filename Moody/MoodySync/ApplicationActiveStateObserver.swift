//
//  ApplicationActiveStateObserver.swift
//  Moody
//
//  Created by Daniel Eggert on 25/07/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit


protocol ObserverTokenStore : class {
    func addObserverToken(token: NSObjectProtocol)
}


/// This is a helper protocol for the SyncCoordinator.
///
/// It receives application active / background state changes and forwards them after switching onto the right queue.
protocol ApplicationActiveStateObserving : class, ObserverTokenStore {
    /// Runs the given block on the right queue and dispatch group.
    func performGroupedBlock(block: () -> ())

    /// Called when the application becomes active (or at launch if it's already active).
    func applicationDidBecomeActive()
    func applicationDidEnterBackground()
}


extension ApplicationActiveStateObserving {
    func setupApplicationActiveNotifications() {
        addObserverToken(NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: nil) { [weak self] note in
            guard let observer = self else { return }
            observer.performGroupedBlock {
                observer.applicationDidEnterBackground()
            }
        })
        addObserverToken(NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { [weak self] note in
            guard let observer = self else { return }
            observer.performGroupedBlock {
                observer.applicationDidBecomeActive()
            }
        })
        if UIApplication.sharedApplication().applicationState == .Active {
            applicationDidBecomeActive()
        }
    }
}
