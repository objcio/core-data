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


public func AssertEqual<T: Equatable>(_ expression1: @autoclosure () -> T?, _ expression2: @autoclosure () -> T?, _ message: String = "", file: StaticString = #file, line: UInt = #line, continuation: () -> () = {}) {
    let a = expression1()
    let b = expression2()
    if a != b {
        XCTFail("\(String(describing: a)) != \(String(describing: b)) \(message)")
    } else {
        continuation()
    }
}


private class TestSyncContext: ContextOwner {

    let viewContext: NSManagedObjectContext
    let syncContext: NSManagedObjectContext
    let syncGroup = DispatchGroup()
    let didSetup = true
    var observerTokens: [NSObjectProtocol] = []

    func addObserverToken(_ token: NSObjectProtocol) {
        observerTokens.append(token)
    }

    init(viewContext: NSManagedObjectContext, syncContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.syncContext = syncContext
        setupContexts()
    }

    var changedObjects: [NSManagedObject] = []

    func processChangedLocalObjects(_ objects: [NSManagedObject]) {
        changedObjects += objects
    }
}


extension DispatchGroup {
    func spinUntilEmpty() {
        var done = false
        self.notify(queue: DispatchQueue.main) {
            done = true
        }
        repeat {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.0001))
        } while !done
    }
}


class SyncContextTests: XCTestCase {

    fileprivate var sut: TestSyncContext? = nil

    override func tearDown() {
        tearDownContext()
        super.tearDown()
    }

    func createContext() {
        let psc = createPersistentStoreCoordinatorWithInMemotyStore()

        // We create both with "private" queue's to keep them off the main thread that the tests are running on.
        let main = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        main.name = "main"
        main.persistentStoreCoordinator = psc
        let sync = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        sync.name = "sync"
        sync.persistentStoreCoordinator = main.persistentStoreCoordinator

        sut = TestSyncContext(viewContext: main, syncContext: sync)
    }

    func tearDownContext() {
        if let context = sut {
            sut = nil
            context.observerTokens = []
            // Wait for work to be done in order not to leak into the next test:
            context.syncGroup.spinUntilEmpty()

            let group = DispatchGroup()
            group.enter()
            context.viewContext.perform {
                group.leave()
            }
            group.enter()
            context.syncContext.perform {
                group.leave()
            }
            group.spinUntilEmpty()
        }
    }

    func waitForManagedObjectContextsToBeDone() {
        let group = DispatchGroup()
        group.enter()
        sut!.viewContext.perform {
            group.leave()
        }
        group.enter()
        sut!.syncContext.perform {
            group.leave()
        }
        group.spinUntilEmpty()
        sut!.syncGroup.spinUntilEmpty()
    }

    fileprivate func insertObject() -> (onMain: TestObject, onSync: TestObject) {
        let group = sut!.syncGroup
        let main = sut!.viewContext
        let sync = sut!.syncContext
        var objectOnMain: TestObject?
        var objectOnSync: TestObject?
        main.perform(group: group) {
            objectOnMain = main.insertObject() as TestObject
            try! main.save()
            sync.perform(group: group) {
                objectOnSync = .some(sync.object(with: objectOnMain!.objectID) as! TestObject)
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
        let main = sut!.viewContext
        main.perform(group: sut!.syncGroup) {
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

