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
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [String: NSObject])
}


private let RemoteTypeEnvKey = "MoodyRemote"


/// This is the central class that coordinates synchronization with the remote backend.
///
/// This classs does not have any model specific knowledge. It relies on multiple `ChangeProcessorType` instances to process changes or communicate with the remote. Change processors have model-specific knowledge.
///
/// The change processors (`ChangeProcessorType`) each have 1 specific aspect of syncing as their role. In our case there are three: one for uploading moods, one for downloading moods, and one for removing moods.
///
/// The `SyncCoordinator` is mostly single-threaded by design. This allows for the code to be relatively simple. All sync code runs on the queue of the `syncManagedObjectContext`. Entry points that may run on another queue **must** switch onto that context's queue using `performGroupedBlock(_:)`.
///
/// Note that inside this class we use `performGroupedBlock(_:)` in lieu of `dispatch_async()` to make sure all work is done on the sync context's queue. Adding asynchronous work to a dispatch group makes it easier to test. We can easily wait for all code to be completed by waiting on that group.
///
/// This class uses the `SyncContextType` and `ApplicationActiveStateObserving` protocols.
public final class SyncCoordinator {

    internal typealias ApplicationDidBecomeActive = () -> ()

    let mainManagedObjectContext: NSManagedObjectContext
    let syncManagedObjectContext: NSManagedObjectContext
    let syncGroup: dispatch_group_t = dispatch_group_create()

    let remote: MoodyRemoteType

    private var observerTokens: [NSObjectProtocol] = [] //< The tokens registered with NSNotificationCenter
    internal let changeProcessors: [ChangeProcessorType] //< The change processors for upload, download, etc.
    private var setupToken = dispatch_once_t()
    var didSetup: Bool { return setupToken != 0 }
    var needsTeardown = Int32(1)

    public init(mainManagedObjectContext mainMOC: NSManagedObjectContext) {
        remote = NSProcessInfo.processInfo().environment[RemoteTypeEnvKey]?.lowercaseString == "console" ? ConsoleRemote() : CloudKitRemote()
        assert(mainMOC.concurrencyType == .MainQueueConcurrencyType)
        mainManagedObjectContext = mainMOC
        syncManagedObjectContext = mainMOC.createBackgroundContext()
        syncManagedObjectContext.name = "SyncCoordinator"
        syncManagedObjectContext.mergePolicy = MoodyMergePolicy(mode: .Remote)
        changeProcessors = [MoodUploader(), MoodDownloader(), MoodRemover()]
        setup()
    }

    /// The `tearDown` method must be called in order to stop the sync coordinator.
    public func tearDown() {
        guard OSAtomicCompareAndSwapInt(1, 0, &needsTeardown) else { return }
        performGroupedBlock {
            self.removeAllObserverTokens()
        }
    }

    deinit {
        guard needsTeardown == 0 else { fatalError("deinit called without tearDown() being called.") }
        // We must not call tearDown() at this point, because we can not call async code from within deinit.
        // We want to be able to call async code inside tearDown() to make sure things run on the right thread.
    }

    private func setup() {
        dispatch_once(&setupToken) {
            self.performGroupedBlock {
                // All these need to run on the same queue, since they're modifying `observerTokens`
                self.remote.fetchUserID { self.mainManagedObjectContext.userID = $0 }
                self.setupContexts()
                self.setupChangeProcessors()
                self.setupApplicationActiveNotifications()
            }
        }
    }

}


extension SyncCoordinator: CloudKitNotificationDrain {
    public func application(application: UIApplication, didReceiveRemoteNotification userInfo: [String: NSObject]) {
        performGroupedBlock {
            self.fetchNewRemoteData()
        }
    }
}


// MARK: - Context Owner -

extension SyncCoordinator: ContextOwnerType {
    /// The sync coordinator holds onto tokens used to register with the NSNotificationCenter.
    func addObserverToken(token: NSObjectProtocol) {
        precondition(didSetup, "Did not call setup()")
        observerTokens.append(token)
    }
    func removeAllObserverTokens() {
        precondition(didSetup, "Did not call setup()")
        observerTokens.removeAll()
    }

    func processChangedLocalObjects(objects: [NSManagedObject]) {
        precondition(didSetup, "Did not call setup()")
        for cp in changeProcessors {
            cp.processChangedLocalObjects(objects, context: self)
        }
    }
}


// MARK: - Context -


extension SyncCoordinator: ChangeProcessorContextType {

    /// This is the context that the sync coordinator, change processors, and other sync components do work on.
    var managedObjectContext: NSManagedObjectContext {
        precondition(didSetup, "Did not call setup()")
        return syncManagedObjectContext
    }

    /// This switches onto the sync context's queue. If we're already on it, it will simply run the block.
    func performGroupedBlock(block: () -> ()) {
        precondition(didSetup, "Did not call setup()")
        syncManagedObjectContext.performBlockWithGroup(syncGroup, block: block)
    }

    func performGroupedBlock<A,B>(block: (A,B) -> ()) -> (A,B) -> () {
        precondition(didSetup, "Did not call setup()")
        return { (a: A, b: B) -> () in
            self.performGroupedBlock {
                block(a, b)
            }
        }
    }

    func performGroupedBlock<A,B,C>(block: (A,B,C) -> ()) -> (A,B,C) -> () {
        precondition(didSetup, "Did not call setup()")
        return { (a: A, b: B, c: C) -> () in
            self.performGroupedBlock {
                block(a, b, c)
            }
        }
    }

    func delayedSaveOrRollback() {
        managedObjectContext.delayedSaveOrRollbackWithGroup(syncGroup)
    }
}


// MARK: Setup
extension SyncCoordinator {

    private func setupChangeProcessors() {
        precondition(didSetup, "Did not call setup()")
        for cp in self.changeProcessors {
            cp.setupForContext(self)
        }
    }
}

// MARK: - Active & Background -

extension SyncCoordinator: ApplicationActiveStateObserving {
    func applicationDidBecomeActive() {
        precondition(didSetup, "Did not call setup()")
        fetchLocallyTrackedObjects()
        fetchRemoteDataForApplicationDidBecomeActive()
    }

    func applicationDidEnterBackground() {
        precondition(didSetup, "Did not call setup()")
        syncManagedObjectContext.refreshAllObjects()
    }

    private func fetchLocallyTrackedObjects() {
        precondition(didSetup, "Did not call setup()")
        self.performGroupedBlock {
            // TODO: Could optimize this to only execute a single fetch request per entity.
            var objects: Set<NSManagedObject> = []
            for cp in self.changeProcessors {
                guard let entityAndPredicate = cp.entityAndPredicateForLocallyTrackedObjectsInContext(self) else { continue }
                let request = entityAndPredicate.fetchRequest
                request.returnsObjectsAsFaults = false
                guard let result = try! self.syncManagedObjectContext.executeFetchRequest(request) as? [NSManagedObject] else { fatalError() }
                objects.unionInPlace(result)
            }
            self.processChangedLocalObjects(Array(objects))
        }
    }

}


// MARK: - Remote -

extension SyncCoordinator {

    private func fetchRemoteDataForApplicationDidBecomeActive() {
        switch Mood.countInContext(managedObjectContext) {
        case 0: self.fetchLatestRemoteData()
        default: self.fetchNewRemoteData()
        }
    }

    private func fetchLatestRemoteData() {
        performGroupedBlock { _ in
            for changeProcessor in self.changeProcessors {
                changeProcessor.fetchLatestRemoteRecordsForContext(self)
                self.delayedSaveOrRollback()
            }
        }
    }

    private func fetchNewRemoteData() {
        remote.fetchNewMoods { changes, callback in
            self.processChangedRemoteObjects(changes) {
                self.performGroupedBlock {
                    self.managedObjectContext.delayedSaveOrRollbackWithGroup(self.syncGroup) { success in
                        callback(success: success)
                    }
                }
            }
        }
    }

    private func processChangedRemoteObjects<T: RemoteRecordType>(changes: [RemoteRecordChange<T>], completion: () -> ()) {
        self.changeProcessors.asyncForEachWithCompletion(completion) { changeProcessor, innerCompletion in
            performGroupedBlock {
                changeProcessor.processChangedRemoteObjects(changes, context: self, completion: innerCompletion)
            }
        }
    }
}
