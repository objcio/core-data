//
//  DelayedDeletePropagationTests.swift
//  Moody
//
//  Created by Florian on 10/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import XCTest
import CoreData
@testable import MoodyModel

class DelayedDeletePropagationTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        managedObjectContext = NSManagedObjectContext.moodyInMemoryTestContext()
    }

    override func tearDown() {
        managedObjectContext = nil
        super.tearDown()
    }

    func testThatDeletingLastMoodInCountryDeletesCountry() {
        // Given
        let mood = managedObjectContext.testInsertMoodsAndSave()[0]
        let country = mood.country!

        // When
        managedObjectContext.testDeleteObject(mood)

        // Then
        XCTAssertNotEqual(country.markedForDeletionDate, nil)
    }

    func testThatDeletingLastMoodInLastCountryOfContinentDeletesContinent() {
        // Given
        let mood = managedObjectContext.testInsertMoodsAndSave()[0]
        let continent = mood.country!.continent!

        // When
        managedObjectContext.testDeleteObject(mood)

        // Then
        XCTAssertNotEqual(continent.markedForDeletionDate, nil)
    }

}

