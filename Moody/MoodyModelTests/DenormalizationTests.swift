//
//  MoodyModelTests.swift
//  MoodyModelTests
//
//  Created by Florian on 10/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import XCTest
import CoreData
@testable import MoodyModel

class DenormalizationTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        managedObjectContext = NSManagedObjectContext.moodyInMemoryTestContext()
    }

    override func tearDown() {
        managedObjectContext = nil
        super.tearDown()
    }

    func testThatInsertingMoodUpdatesTimestampOnCountry() {
        // Given
        let country = managedObjectContext.testInsertMoodsAndSave()[0].country!
        let updatedAt = country.updatedAt

        // When
        managedObjectContext.testInsertMoodsAndSave([country.iso3166Code])

        // Then
        XCTAssertGreaterThan(country.updatedAt, updatedAt)
    }

    func testThatInsertingMoodUpdatesTimestampOnContinent() {
        // Given
        let continent = managedObjectContext.testInsertMoodsAndSave()[0].country!.continent!
        let updatedAt = continent.updatedAt

        // When
        managedObjectContext.testInsertMoodsAndSave([continent.countries.first!.iso3166Code])

        // Then
        XCTAssertGreaterThan(continent.updatedAt, updatedAt)
    }

    func testThatDeletingMoodDoesNotChangeUpdatedAtOnCountry() {
        // Given
        let moods = managedObjectContext.testInsertMoodsAndSave([.DEU, .DEU])
        let country = moods[0].country!
        let updatedAt = country.updatedAt

        // When
        managedObjectContext.testDeleteObject(moods[1])

        // Then
        XCTAssertEqual(country.updatedAt, updatedAt)
    }

    func testThatInsertingMoodUpdatesNumberOfMoodsOnCountry() {
        // Given
        let country = managedObjectContext.testInsertMoodsAndSave()[0].country!

        // When
        managedObjectContext.testInsertMoodsAndSave([country.iso3166Code])

        // Then
        XCTAssertEqual(country.numberOfMoods, 2)
    }

    func testThatInsertingMoodUpdatesNumberOfMoodsOnContinent() {
        // Given
        let continent = managedObjectContext.testInsertMoodsAndSave([.DEU])[0].country!.continent!

        // When
        managedObjectContext.testInsertMoodsAndSave([.DEU, .FRA])

        // Then
        XCTAssertEqual(continent.numberOfMoods, 3)
    }

    func testThatInsertingMoodInNewCountryUpdatesNumberOfCountriesOnContinent() {
        // Given
        let continent = managedObjectContext.testInsertMoodsAndSave([.DEU])[0].country!.continent!

        // When
        managedObjectContext.testInsertMoodsAndSave([.FRA])

        // Then
        XCTAssertEqual(continent.numberOfCountries, 2)
    }

    func testThatDeletingMoodUpdatesNumberOfMoodsOnCountry() {
        // Given
        let moods = managedObjectContext.testInsertMoodsAndSave([.DEU, .DEU])
        let country = moods[0].country!

        // When
        managedObjectContext.testDeleteObject(moods[1])

        // Then
        XCTAssertEqual(country.numberOfMoods, 1)
    }

    func testThatDeletingMoodUpdatesNumberOfMoodsOnContinent() {
        // Given
        let moods = managedObjectContext.testInsertMoodsAndSave([.DEU, .FRA, .FRA])
        let continent = moods[0].country!.continent!

        // When
        managedObjectContext.testDeleteObject(moods[2])

        // Then
        XCTAssertEqual(continent.numberOfMoods, 2)
    }

    func testThatDeletingLastMoodInCountryUpdatesNumberOfCountriesOnContinent() {
        // Given
        let moods = managedObjectContext.testInsertMoodsAndSave([.DEU, .FRA])
        let continent = moods[0].country!.continent!

        // When
        managedObjectContext.testDeleteObject(moods[1])

        // Then
        XCTAssertEqual(continent.numberOfCountries, 1)
    }

    func testThatDeletingLastMoodInCountryUpdatesNumberOfMoodsOnContinent() {
        // Given
        let moods = managedObjectContext.testInsertMoodsAndSave([.DEU, .FRA])
        let continent = moods[0].country!.continent!

        // When
        managedObjectContext.testDeleteObject(moods[1])

        // Then
        XCTAssertEqual(continent.numberOfMoods, 1)
    }

}
