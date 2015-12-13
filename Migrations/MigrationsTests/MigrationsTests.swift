//
//  MigrationsTests.swift
//  MigrationsTests
//
//  Created by Florian on 02/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import XCTest
import CoreData
@testable import Migrations


class MigrationsTests: XCTestCase {

    var targetURL: NSURL!

    override func setUp() {
        super.setUp()
        registerValueTransformers()
        targetURL = NSURL.temporaryURL()
        print("Destination URL: \(targetURL)")
    }

    override func tearDown() {
        super.tearDown()
    }

    // This migration renames `Mood`'s `remoteIdentifier` to `remoteID` and adds a `rating` attribute.
    // It uses an inferred mapping model (aka lightweight migration).
    func testLightWeightMigrationFrom1To2() {
        // Given
        let sourceURL = NSURL.testStoreURLForVersion(.Version1)
        let targetVersion = ModelVersion.Version2

        // When
        migrateStoreFromURL(sourceURL, toURL: targetURL, targetVersion: targetVersion)

        // Then
        XCTAssert(v2Data.matchWithContext(NSManagedObjectContext(model: targetVersion.managedObjectModel(), storeURL: targetURL)))
    }

    // This migration adds a new one-to-many relationship between `Continent` and `Mood`.
    // We use the following custom mapping model:
    //
    // * `Mood`'s `continent` relationship is `FUNCTION($manager, "destinationInstancesForEntityMappingNamed:sourceInstances:" , "ContinentToContinent", $source.country.continent)`.
    // * Continent's `moods` relationship is `FUNCTION($manager, "destinationInstancesForEntityMappingNamed:sourceInstances:" , "MoodToMood", $source.countries.@distinctUnionOfSets.moods)`.
    // * Everything else is mapped 1:1.
    func testMigrationFrom2To3() {
        // Given
        let sourceURL = NSURL.testStoreURLForVersion(.Version2)
        let targetVersion = ModelVersion.Version3

        // When
        migrateStoreFromURL(sourceURL, toURL: targetURL, targetVersion: targetVersion)

        // Then
        XCTAssert(v3Data.matchWithContext(NSManagedObjectContext(model: targetVersion.managedObjectModel(), storeURL: targetURL)))
    }

    // This migration removes the abstract parent entity `GeographicRegion` and makes `Country` and `Continent` standalone entities.
    // We use a custom mapping model where everything is mapped 1:1.
    // Since only the internal structure of the data changes, we compare the result against the `v3Data` test fixture.
    func testMigrationFrom3To4() {
        // Given
        let sourceURL = NSURL.testStoreURLForVersion(.Version3)
        let targetVersion = ModelVersion.Version4

        // When
        migrateStoreFromURL(sourceURL, toURL: targetURL, targetVersion: targetVersion)

        // Then
        XCTAssert(v3Data.matchWithContext(NSManagedObjectContext(model: targetVersion.managedObjectModel(), storeURL: targetURL)))
    }

    // This migration removes the `Continent` entity and adds a `isoContinent` integer attribute on `Country` instead.
    // We use the following custom mapping model:
    //
    // * `Country`'s `isoContinent` is `$source.continent.numericISO3166Code`.
    // * The `Continent` entity doesn't get mapped.
    // * Everything else is mapped 1:1.
    func testMigrationFrom4To5() {
        // Given
        let sourceURL = NSURL.testStoreURLForVersion(.Version4)
        let targetVersion = ModelVersion.Version5

        // When
        migrateStoreFromURL(sourceURL, toURL: targetURL, targetVersion: targetVersion)

        // Then
        XCTAssert(v5Data.matchWithContext(NSManagedObjectContext(model: targetVersion.managedObjectModel(), storeURL: targetURL)))
    }

    // This migration adds back the `Continent` entity with a one-to-many relationship to `Country`, removing the `isoContinent` attribute on `Country`.
    // In the custom mapping model everything is mapped 1:1, but the `CountryToCountry` mapping uses a custom policy `Country5toCountry6Policy`, which creates the `Continent` entities and associates them with the existing countries.
    func testMigrationFrom5To6() {
        // Given
        let sourceURL = NSURL.testStoreURLForVersion(.Version5)
        let targetVersion = ModelVersion.Version6

        // When
        migrateStoreFromURL(sourceURL, toURL: targetURL, targetVersion: targetVersion)

        // Then
        XCTAssert(v6Data.matchWithContext(NSManagedObjectContext(model: targetVersion.managedObjectModel(), storeURL: targetURL)))
    }

    // This migration migrates a version 1 store to a version 6 store by progressively applying the intermediate migrations.
    func testProgressiveMigrationFrom1To6() {
        // Given
        let sourceURL = NSURL.testStoreURLForVersion(.Version1)
        let targetVersion = ModelVersion.Version6

        // When
        migrateStoreFromURL(sourceURL, toURL: targetURL, targetVersion: targetVersion)

        // Then
        XCTAssert(v6Data.matchWithContext(NSManagedObjectContext(model: targetVersion.managedObjectModel(), storeURL: targetURL)))
    }

}
