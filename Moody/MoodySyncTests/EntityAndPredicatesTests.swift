//
//  EntityAndPredicatesTests.swift
//  MoodySyncTests
//
//  Created by Daniel Eggert on 23/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import XCTest
import CoreData
@testable import MoodySync


class EntityAndPredicatesTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext! = nil

    override func setUp() {
        super.setUp()

        managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.name = "EntityAndPredicatesTests"
        managedObjectContext.persistentStoreCoordinator = createPersistentStoreCoordinatorWithInMemotyStore()
    }

    override func tearDown() {
        managedObjectContext = nil
        super.tearDown()
    }

    func testThatItMapsTheEntityName() {
        // Given
        let entity = managedObjectContext.persistentStoreCoordinator!.managedObjectModel.entitiesByName[TestObject.entityName]!

        // When
        let sut = EntityAndPredicate(entityName: TestObject.entityName, predicate: NSPredicate(value: true), context: managedObjectContext)

        // Then
        XCTAssert(sut.entity === entity)
    }

    func testThatItBuildsAFetchRequest() {
        // Given
        managedObjectContext.performBlockAndWait {
            let moA: TestObject = self.managedObjectContext.insertObject()
            moA.name = "A"
            let moB: TestObject = self.managedObjectContext.insertObject()
            moB.name = "B"
            try! self.managedObjectContext.save()
        }
        let sut = EntityAndPredicate(entityName: TestObject.entityName, predicate: NSPredicate(format: "%K == %@", "name", "B"), context: managedObjectContext)

        // When
        let match = try! managedObjectContext.executeFetchRequest(sut.fetchRequest)

        // Then
        XCTAssertEqual(match.count, 1)
        let mo: TestObject? = match.first as? TestObject
        XCTAssertEqual(mo?.name, "B")
    }
}
