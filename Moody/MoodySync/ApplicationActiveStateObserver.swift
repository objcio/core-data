//
//  ApplicationActiveStateObserver.swift
//  Moody
//
//  Created by Daniel Eggert on 25/07/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit


protocol ObserverTokenStore : class {
    func addObserverToken(_ token: NSObjectProtocol)
}


/// This is a helper protocol for the SyncCoordinator.
///
/// It receives application active / background state changes and forwards them after switching onto the right queue.
protocol ApplicationActiveStateObserving : class, ObserverTokenStore {
    /// Runs the given block on the right queue and dispatch group.
    func perform(_ block: @escaping () -> ())

    /// Called when the application becomes active (or at launch if it's already active).
    func applicationDidBecomeActive()
    func applicationDidEnterBackground()
}


extension ApplicationActiveStateObserving {
    func setupApplicationActiveNotifications() {
        addObserverToken(NotificationCenter.default.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: nil) { [weak self] note in
            guard let observer = self else { return }
            observer.perform {
                observer.applicationDidEnterBackground()
            }
        })
        addObserverToken(NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] note in
            guard let observer = self else { return }
            observer.perform {
                observer.applicationDidBecomeActive()
            }
        })
        DispatchQueue.main.async {
            if UIApplication.shared.applicationState == .active {
                self.applicationDidBecomeActive()
            }
        }
    }
}

