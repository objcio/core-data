//
//  InProgressTrackerTests.swift
//  Moody
//
//  Created by Daniel Eggert on 23/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import XCTest
import CoreData
import CoreDataHelpers
@testable import MoodySync


class InProgressTrackerTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext! = nil
    var moA: TestObject! = nil
    var moB: TestObject! = nil
    var moC: TestObject! = nil
    var moD: TestObject! = nil

    override func setUp() {
        super.setUp()

        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.name = "InProgressTrackerTests"
        managedObjectContext.persistentStoreCoordinator = createPersistentStoreCoordinatorWithInMemotyStore()

        moA = managedObjectContext.insertObject() as TestObject
        moA.name = "A"
        moB = managedObjectContext.insertObject() as TestObject
        moB.name = "B"
        moC = managedObjectContext.insertObject() as TestObject
        moC.name = "C"
        moD = managedObjectContext.insertObject() as TestObject
        moD.name = "D"
        try! managedObjectContext.save()
    }

    override func tearDown() {
        managedObjectContext = nil
        moA = nil
        moB = nil
        moC = nil
        moD = nil
        super.tearDown()
    }

    func testThatAddingObjectsFirstTimeReturnsAllObjects() {
        // Given
        let sut = InProgressTracker<TestObject>()

        // When
        let result = sut.objectsToProcess(from: [moA, moB])

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains(moA))
        XCTAssertTrue(result.contains(moB))
    }

    func testThatAddingObjectsTwiceDoesNotReturnAnythingTheSecondTime() {
        // Given
        let sut = InProgressTracker<TestObject>()

        // When
        let _ = sut.objectsToProcess(from: [moA, moB])
        let result = sut.objectsToProcess(from: [moA, moB])

        // Then
        XCTAssertEqual(result.count, 0)
    }

    func testThatAddingAMixOfExistingAndNewObjectsReturnsTheNewOnes() {
        // Given
        let sut = InProgressTracker<TestObject>()

        // When
        let _ = sut.objectsToProcess(from: [moA, moB])
        let result = sut.objectsToProcess(from: [moC, moA, moB, moD])

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains(moC))
        XCTAssertTrue(result.contains(moD))
    }

    func testThatAddingObjectsAfterTheyHaveBeenMarkedAsCompleteAddsThemAgain() {
        // Given
        let sut = InProgressTracker<TestObject>()

        // When
        let _ = sut.objectsToProcess(from: [moA, moB, moC])
        sut.markObjectsAsComplete([moA, moC])
        let result = sut.objectsToProcess(from: [moA, moB, moC, moD])

        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.contains(moA))
        XCTAssertTrue(result.contains(moC))
        XCTAssertTrue(result.contains(moD))
    }
}

