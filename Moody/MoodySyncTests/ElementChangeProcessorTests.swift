//
//  ElementChangeProcessorTests.swift
//  Moody
//
//  Created by Daniel Eggert on 23/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import XCTest
import CoreData
import MoodyModel
@testable import MoodySync


private class TestChangeProcessor: ElementChangeProcessorType {

    typealias Element = TestObject
    let elementsInProgress = InProgressTracker<TestObject>()

    func setupForContext(context: ChangeProcessorContextType) {
        // no-op
    }

    private var changedElements: [TestObject] = []

    func processChangedLocalElements(objects: [TestObject], context: ChangeProcessorContextType) {
        changedElements += objects
    }

    func processChangedRemoteObjects<T: RemoteRecordType>(changes: [RemoteRecordChange<T>], context: ChangeProcessorContextType, completion: () -> ()) {
        completion()
    }

    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
    }

    var predicateForLocallyTrackedElements: NSPredicate {
        return NSPredicate(format: "%K == %@", "name", "A")
    }
}


private class TestContext: ChangeProcessorContextType {
    let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    var remote: MoodyRemoteType {
        // Intentionally not implemented
        fatalError()
    }

    func performGroupedBlock(block: () -> ()) {
        block()
    }

    func performGroupedBlock<A,B>(block: (A,B) -> ()) -> (A,B) -> () {
        return {  (a: A, b: B) -> () in
            block(a, b)
        }
    }

    func performGroupedBlock<A,B,C>(block: (A,B,C) -> ()) -> (A,B,C) -> () {
        return {  (a: A, b: B, c: C) -> () in
            block(a, b, c)
        }
    }

    func delayedSaveOrRollback() {
        XCTFail()
    }
}


class ElementChangeProcessorTests: XCTestCase {

    private var managedObjectContext: NSManagedObjectContext! = nil
    private var context: TestContext! = nil

    override func setUp() {
        super.setUp()

        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.name = "ElementChangeProcessorTests"
        managedObjectContext.persistentStoreCoordinator = createPersistentStoreCoordinatorWithInMemotyStore()

        context = TestContext(managedObjectContext: managedObjectContext)
    }

    override func tearDown() {
        managedObjectContext = nil
        context = nil
        super.tearDown()
    }

    func testThatForwardsMatchingObjects() {
        // Given
        let mo1: TestObject = managedObjectContext.insertObject()
        mo1.name = "A"
        let mo2: TestObject = managedObjectContext.insertObject()
        mo2.name = "A"
        try! managedObjectContext.save()

        let sut = TestChangeProcessor()

        // When
        sut.processChangedLocalObjects([mo1, mo2], context: context)

        // Then
        XCTAssertEqual(sut.changedElements.count, 2)
        XCTAssertTrue(sut.changedElements.contains(mo1))
        XCTAssertTrue(sut.changedElements.contains(mo2))
    }

    func testThatDoesNotForwardNonMatchingObjects() {
        // Given
        let mo1: TestObject = managedObjectContext.insertObject()
        mo1.name = "A"
        let mo2: TestObject = managedObjectContext.insertObject()
        mo2.name = "B"
        try! managedObjectContext.save()

        let sut = TestChangeProcessor()

        // When
        sut.processChangedLocalObjects([mo1, mo2], context: context)

        // Then
        XCTAssertEqual(sut.changedElements.count, 1)
        XCTAssertTrue(sut.changedElements.contains(mo1))
        XCTAssertTrue(!sut.changedElements.contains(mo2))
    }

    func testThatDoesNotForwardObjectsOfAnotherEntity() {
        // Given
        let mo1: TestObject = managedObjectContext.insertObject()
        mo1.name = "A"
        let mo2: TestObjectB = managedObjectContext.insertObject()
        mo2.name = "A"
        try! managedObjectContext.save()

        let sut = TestChangeProcessor()

        // When
        sut.processChangedLocalObjects([mo1, mo2], context: context)

        // Then
        XCTAssertEqual(sut.changedElements.count, 1)
        XCTAssertTrue(sut.changedElements.contains(mo1))
    }
}

// MARK: Objects that are In-Progress Testing

extension ElementChangeProcessorTests {

    func testThatItDoesNotForwardObjectIfTheyAreAlreadyInProgress() {
        // Given
        let mo: TestObject = managedObjectContext.insertObject()
        mo.name = "A"
        try! managedObjectContext.save()

        let sut = TestChangeProcessor()

        // When
        sut.processChangedLocalObjects([mo], context: context)
        sut.changedElements = []
        sut.processChangedLocalObjects([mo], context: context)

        // Then
        XCTAssertEqual(sut.changedElements.count, 0)
    }

    func testThatItForwardsAnObjectAgainWhenItIsBeingMarkedAsCompleteIfItStillMatches() {
        // Given
        let mo: TestObject = managedObjectContext.insertObject()
        mo.name = "A"
        try! managedObjectContext.save()

        let sut = TestChangeProcessor()

        // When
        sut.processChangedLocalObjects([mo], context: context)
        sut.changedElements = []
        sut.didCompleteElements([mo], context: context)

        // Then
        XCTAssertEqual(sut.changedElements.count, 1)
        XCTAssertTrue(sut.changedElements.contains(mo))
    }

    func testThatItForwardsAnObjectAgainOnceIsHasBeenMarkedAsComplete() {
        // Given
        let mo: TestObject = managedObjectContext.insertObject()
        mo.name = "A"
        try! managedObjectContext.save()

        let sut = TestChangeProcessor()

        // When
        sut.processChangedLocalObjects([mo], context: context)
        // Make sure it no longer matches & mark as complete:
        mo.name = "B"
        try! managedObjectContext.save()
        sut.didCompleteElements([mo], context: context)
        // Re-add:
        mo.name = "A"
        try! managedObjectContext.save()
        sut.changedElements = []
        sut.processChangedLocalObjects([mo], context: context)

        // Then
        XCTAssertEqual(sut.changedElements.count, 1)
        XCTAssertTrue(sut.changedElements.contains(mo))
    }

}
