//
//  MoodyMergePolicyTests.swift
//  Moody
//
//  Created by Florian on 10/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import XCTest
import CoreData
import CoreDataHelpers
@testable import MoodyModel

class MoodyMergePolicyTests: XCTestCase {

    var managedObjectContext1: NSManagedObjectContext!
    var managedObjectContext2: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        managedObjectContext1 = NSManagedObjectContext.moodyInMemoryTestContext()
        managedObjectContext2 = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext2.persistentStoreCoordinator = managedObjectContext1.persistentStoreCoordinator
        managedObjectContext1.mergePolicy = MoodyMergePolicy(mode: .Local)
        managedObjectContext2.mergePolicy = MoodyMergePolicy(mode: .Local)
    }

    override func tearDown() {
        managedObjectContext1 = nil
        managedObjectContext2 = nil
        super.tearDown()
    }

    func testThatConflictedUpdatedAtResolvesToLatestDate() {
        // Given
        let country1 = managedObjectContext1.testInsertMoodsAndSave()[0].country!.materialize()
        let country2 = country1.materializedObjectInContext(managedObjectContext2)
        let winningDate = NSDate(timeIntervalSinceNow: 20)

        // When
        managedObjectContext1.performChangesAndWait {
            country1.updatedAt = winningDate
        }
        managedObjectContext2.performChangesAndWait {
            country2.updatedAt = NSDate(timeIntervalSinceNow: 10)
        }
        managedObjectContext2.refreshAllObjects()

        // Then
        XCTAssertEqual(country2.updatedAt, winningDate)
    }

    func testThatConflictedNumberOfMoodsOnCountryResolvesToPersistedState() {
        // Given
        let country1 = managedObjectContext1.testInsertMoodsAndSave([.DEU])[0].country!
        managedObjectContext2.testInsertMoodsAndSave([.DEU])

        // When
        managedObjectContext1.performChangesAndWait {
            self.managedObjectContext1.testInsertMoodsAndSave([.DEU])
        }

        // Then
        XCTAssertEqual(country1.numberOfMoods, 3)
    }

    func testThatConflictedNumberOfMoodsOnContinentResolvesToPersistedState() {
        // Given
        let continent1 = managedObjectContext1.testInsertMoodsAndSave([.DEU])[0].country!.continent!
        managedObjectContext2.testInsertMoodsAndSave([.DEU])

        // When
        managedObjectContext1.performChangesAndWait {
            self.managedObjectContext1.testInsertMoodsAndSave([.DEU])
        }

        // Then
        XCTAssertEqual(continent1.numberOfMoods, 3)
    }

    func testThatConflictedNumberOfCountriesOnContinentResolvesToPersistedState() {
        // Given
        let continent1 = managedObjectContext1.testInsertMoodsAndSave([.DEU])[0].country!.continent!
        managedObjectContext2.testInsertMoodsAndSave([.FRA])

        // When
        managedObjectContext1.performChangesAndWait {
            self.managedObjectContext1.testInsertMoodsAndSave([.POL])
        }

        // Then
        XCTAssertEqual(continent1.numberOfCountries, 3)
    }

}


class MoodyMergePolicyConstraintTests: XCTestCase {

    var managedObjectContext1: NSManagedObjectContext!
    var managedObjectContext2: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        managedObjectContext1 = NSManagedObjectContext.moodySQLiteTestContext()
        managedObjectContext2 = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext2.persistentStoreCoordinator = managedObjectContext1.persistentStoreCoordinator
        managedObjectContext1.mergePolicy = MoodyMergePolicy(mode: .Local)
        managedObjectContext2.mergePolicy = MoodyMergePolicy(mode: .Local)
    }

    override func tearDown() {
        managedObjectContext1 = nil
        managedObjectContext2 = nil
        super.tearDown()
    }

    func testThatRegionIsoCodeIsEnforcedToBeUnique() {
        // Given
        let m1 = managedObjectContext1.testInsertMoods([.DEU])[0]
        let m2 = managedObjectContext2.testInsertMoodsAndSave([.DEU])[0]

        // When
        try! managedObjectContext1.save()

        // Then
        XCTAssertEqual(m1.country!.objectID, m2.country!.objectID)
        XCTAssertEqual(m1.country!.continent!.objectID, m2.country!.continent!.objectID)
        XCTAssertEqual(m1.country!.numberOfMoods, 2)
        XCTAssertEqual(m1.country!.continent!.numberOfCountries, 1)
        XCTAssertEqual(m1.country!.continent!.numberOfMoods, 2)
    }

}

