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


private class TestChangeProcessor: ElementChangeProcessor {

    typealias Element = TestObject
    let elementsInProgress = InProgressTracker<TestObject>()

    func setup(for context: ChangeProcessorContext) {
        // no-op
    }

    fileprivate var changedElements: [TestObject] = []

    func processChangedLocalElements(_ elements: [TestObject], in context: ChangeProcessorContext) {
        changedElements += elements
    }

    func processRemoteChanges<T: RemoteRecord>(_ changes: [RemoteRecordChange<T>], in context: ChangeProcessorContext, completion: () -> ()) {
        completion()
    }

    func fetchLatestRemoteRecords(in context: ChangeProcessorContext) {
    }

    var predicateForLocallyTrackedElements: NSPredicate {
        return NSPredicate(format: "%K == %@", "name", "A")
    }
}


private class TestContext: ChangeProcessorContext {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    var remote: MoodyRemote {
        // Intentionally not implemented
        fatalError()
    }

    func perform(_ block: @escaping () -> ()) {
        block()
    }

    func perform<A,B>(_ block: @escaping (A,B) -> ()) -> (A,B) -> () {
        return {  (a: A, b: B) -> () in
            block(a, b)
        }
    }

    func perform<A,B,C>(_ block: @escaping (A,B,C) -> ()) -> (A,B,C) -> () {
        return {  (a: A, b: B, c: C) -> () in
            block(a, b, c)
        }
    }

    func delayedSaveOrRollback() {
        XCTFail()
    }
}


class ElementChangeProcessorTests: XCTestCase {

    fileprivate var managedObjectContext: NSManagedObjectContext! = nil
    fileprivate var context: TestContext! = nil

    override func setUp() {
        super.setUp()

        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.name = "ElementChangeProcessorTests"
        managedObjectContext.persistentStoreCoordinator = createPersistentStoreCoordinatorWithInMemotyStore()

        context = TestContext(context: managedObjectContext)
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
        sut.processChangedLocalObjects([mo1, mo2], in: context)

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
        sut.processChangedLocalObjects([mo1, mo2], in: context)

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
        sut.processChangedLocalObjects([mo1, mo2], in: context)

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
        sut.processChangedLocalObjects([mo], in: context)
        sut.changedElements = []
        sut.processChangedLocalObjects([mo], in: context)

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
        sut.processChangedLocalObjects([mo], in: context)
        sut.changedElements = []
        sut.didComplete([mo], in: context)

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
        sut.processChangedLocalObjects([mo], in: context)
        // Make sure it no longer matches & mark as complete:
        mo.name = "B"
        try! managedObjectContext.save()
        sut.didComplete([mo], in: context)
        // Re-add:
        mo.name = "A"
        try! managedObjectContext.save()
        sut.changedElements = []
        sut.processChangedLocalObjects([mo], in: context)

        // Then
        XCTAssertEqual(sut.changedElements.count, 1)
        XCTAssertTrue(sut.changedElements.contains(mo))
    }

}

