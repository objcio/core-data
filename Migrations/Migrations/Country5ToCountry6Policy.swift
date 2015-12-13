//
//  Country5ToCountry6Policy.swift
//  Migrations
//
//  Created by Florian on 05/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


class Country5ToCountry6Policy: NSEntityMigrationPolicy {
    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject, entityMapping mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createDestinationInstancesForSourceInstance(sInstance, entityMapping: mapping, manager: manager)
        guard let continentCode = sInstance.isoContinent else { return }
        guard let country = manager.destinationInstancesForEntityMappingNamed(mapping.name, sourceInstances: [sInstance]).first
            else { fatalError("must return country") }
        guard let context = country.managedObjectContext else { fatalError("must have context") }
        let continent = context.findOrCreateContinent(continentCode)
        country.setContinent(continent)
    }
}


private let NumericISO3166CodeKey = "numericISO3166Code"
private let IsoContinentKey = "isoContinent"
private let ContinentKey = "continent"
private let ContinentEntityName = "Continent"
private let CountryEntityName = "Country"

extension NSManagedObject {
    private var isoContinent: NSNumber? {
        return valueForKey(IsoContinentKey) as? NSNumber
    }

    private func setContinent(continent: NSManagedObject) {
        setValue(continent, forKey: ContinentKey)
    }

    private func isContinentWithCode(code: NSNumber) -> Bool {
        return entity.name == ContinentEntityName && (valueForKey(NumericISO3166CodeKey) as? NSNumber) == code
    }
}

extension NSManagedObjectContext {
    private func findOrCreateContinent(isoCode: NSNumber) -> NSManagedObject {
        guard let continent = materializedObjectPassingTest({ $0.isContinentWithCode(isoCode) }) else {
            let continent = NSEntityDescription.insertNewObjectForEntityForName(ContinentEntityName, inManagedObjectContext: self)
            continent.setValue(isoCode, forKey: NumericISO3166CodeKey)
            return continent
        }
        return continent
    }
}
