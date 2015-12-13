//
//  SyncContextTests.swift
//  MoodySyncTests
//
//  Created by Daniel Eggert on 24/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation
import XCTest
import CoreData
import CoreDataHelpers
@testable import MoodySync


public func AssertEqual<T: Equatable>(@autoclosure expression1: () -> T?, @autoclosure _ expression2: () -> T?, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__, @noescape continuation: () -> () = {}) {
    let a = expression1()
    let b = expression2()
    if a != b {
        XCTFail("\(a) != \(b) \(message)")
    } else {
        continuation()
    }
}


private class TestSyncContext: ContextOwnerType {

    let mainManagedObjectContext: NSManagedObjectContext
    let syncManagedObjectContext: NSManagedObjectContext
    let syncGroup = dispatch_group_create()!
    let didSetup = true
    var observerTokens: [NSObjectProtocol] = []
    func addObserverToken(token: NSObjectProtocol) {
        observerTokens.append(token)
    }

    init(mainManagedObjectContext: NSManagedObjectContext, syncManagedObjectContext: NSManagedObjectContext) {
        self.mainManagedObjectContext = mainManagedObjectContext
        self.syncManagedObjectContext = syncManagedObjectContext
        setupContexts()
    }

    var changedObjects: [NSManagedObject] = []

    func processChangedLocalObjects(managedObjects: [NSManagedObject]) {
        changedObjects += managedObjects
    }
}


extension dispatch_group_t {
    func spinUntilEmpty() {
        var done = false
        dispatch_group_notify(self, dispatch_get_main_queue()) {
            done = true
        }
        repeat {
            NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.0001))
        } while !done
    }
}


class SyncContextTests: XCTestCase {

    private var sut: TestSyncContext? = nil

    override func tearDown() {
        tearDownContext()
        super.tearDown()
    }

    func createContext() {
        let psc = createPersistentStoreCoordinatorWithInMemotyStore()

        // We create both with "private" queue's to keep them off the main thread that the tests are running on.
        let main = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        main.name = "main"
        main.persistentStoreCoordinator = psc
        let sync = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        sync.name = "sync"
        sync.persistentStoreCoordinator = main.persistentStoreCoordinator

        sut = TestSyncContext(mainManagedObjectContext: main, syncManagedObjectContext: sync)
    }

    func tearDownContext() {
        if let context = sut {
            sut = nil
            context.observerTokens = []
            // Wait for work to be done in order not to leak into the next test:
            context.syncGroup.spinUntilEmpty()

            let group = dispatch_group_create()!
            dispatch_group_enter(group)
            context.mainManagedObjectContext.performBlock {
                dispatch_group_leave(group)
            }
            dispatch_group_enter(group)
            context.syncManagedObjectContext.performBlock {
                dispatch_group_leave(group)
            }
            group.spinUntilEmpty()
        }
    }

    func waitForManagedObjectContextsToBeDone() {
        let group = dispatch_group_create()!
        dispatch_group_enter(group)
        sut!.mainManagedObjectContext.performBlock {
            dispatch_group_leave(group)
        }
        dispatch_group_enter(group)
        sut!.syncManagedObjectContext.performBlock {
            dispatch_group_leave(group)
        }
        group.spinUntilEmpty()
        sut!.syncGroup.spinUntilEmpty()
    }

    private func insertObject() -> (onMain: TestObject, onSync: TestObject) {
        let group = sut!.syncGroup
        let main = sut!.mainManagedObjectContext
        let sync = sut!.syncManagedObjectContext
        var objectOnMain: TestObject?
        var objectOnSync: TestObject?
        main.performBlockWithGroup(group) {
            objectOnMain = main.insertObject() as TestObject
            try! main.save()
            sync.performBlockWithGroup(group) {
                objectOnSync = .Some(sync.objectWithID(objectOnMain!.objectID) as! TestObject)
            }
        }
        waitForManagedObjectContextsToBeDone()
        return (onMain: objectOnMain!, onSync: objectOnSync!)
    }

    func testThatInsertingOnTheMainContextSendsLocalChanges() {
        // Given
        createContext()

        // When
        let (onMain: _, onSync: mo) = insertObject()

        // Then
        AssertEqual(sut!.changedObjects.count, 1) {
            XCTAssert(sut!.changedObjects.first! === mo)
        }
    }

    func testThatUpdatingOnTheMainContextSendsLocalChanges() {
        // Given
        createContext()
        let (onMain: objectOnMain, onSync: mo) = insertObject()
        waitForManagedObjectContextsToBeDone()
        sut!.changedObjects = []

        // When
        let main = sut!.mainManagedObjectContext
        main.performBlockWithGroup(sut!.syncGroup) {
            objectOnMain.name = "New Name"
            try! main.save()
        }
        waitForManagedObjectContextsToBeDone()

        // Then
        AssertEqual(sut!.changedObjects.count, 1) {
            XCTAssert(sut!.changedObjects.first! === mo)
        }
    }

}
