//
//  RemoteSync.swift
//  Moody
//
//  Created by Daniel Eggert on 22/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation
import CoreData
import MoodyModel


public protocol CloudKitNotificationDrain {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any])
}


private let RemoteTypeEnvKey = "MoodyRemote"


/// This is the central class that coordinates synchronization with the remote backend.
///
/// This classs does not have any model specific knowledge. It relies on multiple `ChangeProcessor` instances to process changes or communicate with the remote. Change processors have model-specific knowledge.
///
/// The change processors (`ChangeProcessor`) each have 1 specific aspect of syncing as their role. In our case there are three: one for uploading moods, one for downloading moods, and one for removing moods.
///
/// The `SyncCoordinator` is mostly single-threaded by design. This allows for the code to be relatively simple. All sync code runs on the queue of the `syncContext`. Entry points that may run on another queue **must** switch onto that context's queue using `perform(_:)`.
///
/// Note that inside this class we use `perform(_:)` in lieu of `dispatch_async()` to make sure all work is done on the sync context's queue. Adding asynchronous work to a dispatch group makes it easier to test. We can easily wait for all code to be completed by waiting on that group.
///
/// This class uses the `SyncContextType` and `ApplicationActiveStateObserving` protocols.
public final class SyncCoordinator {

    internal typealias ApplicationDidBecomeActive = () -> ()

    let viewContext: NSManagedObjectContext
    let syncContext: NSManagedObjectContext
    let syncGroup: DispatchGroup = DispatchGroup()

    let remote: MoodyRemote

    fileprivate var observerTokens: [NSObjectProtocol] = [] //< The tokens registered with NotificationCenter
    let changeProcessors: [ChangeProcessor] //< The change processors for upload, download, etc.
    var teardownFlag = atomic_flag()

    public init(container: NSPersistentContainer) {
        remote = ProcessInfo.processInfo.environment[RemoteTypeEnvKey]?.lowercased() == "console" ? ConsoleRemote() : CloudKitRemote()
        viewContext = container.viewContext
        syncContext = container.newBackgroundContext()
        syncContext.name = "SyncCoordinator"
        syncContext.mergePolicy = MoodyMergePolicy(mode: .remote)
        changeProcessors = [MoodUploader(), MoodDownloader(), MoodRemover()]
        setup()
    }

    /// The `tearDown` method must be called in order to stop the sync coordinator.
    public func tearDown() {
        guard !atomic_flag_test_and_set(&teardownFlag) else { return }
        perform {
            self.removeAllObserverTokens()
        }
    }

    deinit {
        guard atomic_flag_test_and_set(&teardownFlag) else { fatalError("deinit called without tearDown() being called.") }
        // We must not call tearDown() at this point, because we can not call async code from within deinit.
        // We want to be able to call async code inside tearDown() to make sure things run on the right thread.
    }

    fileprivate func setup() {
        self.perform {
            // All these need to run on the same queue, since they're modifying `observerTokens`
            self.remote.fetchUserID { self.viewContext.userID = $0 }
            self.setupContexts()
            self.setupChangeProcessors()
            self.setupApplicationActiveNotifications()
        }
    }

}


extension SyncCoordinator: CloudKitNotificationDrain {
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        perform {
            self.fetchNewRemoteData()
        }
    }
}


// MARK: - Context Owner -

extension SyncCoordinator : ContextOwner {
    /// The sync coordinator holds onto tokens used to register with the NotificationCenter.
    func addObserverToken(_ token: NSObjectProtocol) {
        observerTokens.append(token)
    }
    func removeAllObserverTokens() {
        observerTokens.removeAll()
    }

    func processChangedLocalObjects(_ objects: [NSManagedObject]) {
        for cp in changeProcessors {
            cp.processChangedLocalObjects(objects, in: self)
        }
    }
}


// MARK: - Context -


extension SyncCoordinator: ChangeProcessorContext {

    /// This is the context that the sync coordinator, change processors, and other sync components do work on.
    var context: NSManagedObjectContext {
        return syncContext
    }

    /// This switches onto the sync context's queue. If we're already on it, it will simply run the block.
    func perform(_ block: @escaping () -> ()) {
        syncContext.perform(group: syncGroup, block: block)
    }

    func perform<A,B>(_ block: @escaping (A,B) -> ()) -> (A,B) -> () {
        return { (a: A, b: B) -> () in
            self.perform {
                block(a, b)
            }
        }
    }

    func perform<A,B,C>(_ block: @escaping (A,B,C) -> ()) -> (A,B,C) -> () {
        return { (a: A, b: B, c: C) -> () in
            self.perform {
                block(a, b, c)
            }
        }
    }

    func delayedSaveOrRollback() {
        context.delayedSaveOrRollback(group: syncGroup)
    }
}


// MARK: Setup
extension SyncCoordinator {
    fileprivate func setupChangeProcessors() {
        for cp in self.changeProcessors {
            cp.setup(for: self)
        }
    }
}

// MARK: - Active & Background -

extension SyncCoordinator: ApplicationActiveStateObserving {
    func applicationDidBecomeActive() {
        fetchLocallyTrackedObjects()
        fetchRemoteDataForApplicationDidBecomeActive()
    }

    func applicationDidEnterBackground() {
        syncContext.refreshAllObjects()
    }

    fileprivate func fetchLocallyTrackedObjects() {
        self.perform {
            // TODO: Could optimize this to only execute a single fetch request per entity.
            var objects: Set<NSManagedObject> = []
            for cp in self.changeProcessors {
                guard let entityAndPredicate = cp.entityAndPredicateForLocallyTrackedObjects(in: self) else { continue }
                let request = entityAndPredicate.fetchRequest
                request.returnsObjectsAsFaults = false
                let result = try! self.syncContext.fetch(request)
                objects.formUnion(result)
            }
            self.processChangedLocalObjects(Array(objects))
        }
    }

}


// MARK: - Remote -

extension SyncCoordinator {
    fileprivate func fetchRemoteDataForApplicationDidBecomeActive() {
        switch Mood.count(in: context) {
        case 0: self.fetchLatestRemoteData()
        default: self.fetchNewRemoteData()
        }
    }

    fileprivate func fetchLatestRemoteData() {
        perform {
            for changeProcessor in self.changeProcessors {
                changeProcessor.fetchLatestRemoteRecords(in: self)
                self.delayedSaveOrRollback()
            }
        }
    }

    fileprivate func fetchNewRemoteData() {
        remote.fetchNewMoods { changes, callback in
            self.processRemoteChanges(changes) {
                self.perform {
                    self.context.delayedSaveOrRollback(group: self.syncGroup) { success in
                        callback(success)
                    }
                }
            }
        }
    }

    fileprivate func processRemoteChanges<T>(_ changes: [RemoteRecordChange<T>], completion: @escaping () -> ()) {
        self.changeProcessors.asyncForEach(completion: completion) { changeProcessor, innerCompletion in
            perform {
                changeProcessor.processRemoteChanges(changes, in: self, completion: innerCompletion)
            }
        }
    }
}

