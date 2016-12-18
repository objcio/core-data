//
//  Country5ToCountry6Policy.swift
//  Migrations
//
//  Created by Florian on 05/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


final class Country5ToCountry6Policy: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
        guard let continentCode = sInstance.isoContinent else { return }
        guard let country = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]).first
            else { fatalError("must return country") }
        guard let context = country.managedObjectContext else { fatalError("must have context") }
        let continent = context.findOrCreateContinent(withISOCode: continentCode)
        country.setContinent(continent)
    }
}


private let NumericISO3166CodeKey = "numericISO3166Code"
private let IsoContinentKey = "isoContinent"
private let ContinentKey = "continent"
private let ContinentEntityName = "Continent"
private let CountryEntityName = "Country"

extension NSManagedObject {
    fileprivate var isoContinent: NSNumber? {
        return value(forKey: IsoContinentKey) as? NSNumber
    }

    fileprivate func setContinent(_ continent: NSManagedObject) {
        setValue(continent, forKey: ContinentKey)
    }

    fileprivate func isContinent(withCode code: NSNumber) -> Bool {
        return entity.name == ContinentEntityName && (value(forKey: NumericISO3166CodeKey) as? NSNumber) == code
    }
}

extension NSManagedObjectContext {
    fileprivate func findOrCreateContinent(withISOCode isoCode: NSNumber) -> NSManagedObject {
        guard let continent = materializedObject(matching: { $0.isContinent(withCode:isoCode) }) else {
            let continent = NSEntityDescription.insertNewObject(forEntityName: ContinentEntityName, into: self)
            continent.setValue(isoCode, forKey: NumericISO3166CodeKey)
            return continent
        }
        return continent
    }

    fileprivate func materializedObject(matching condition: (NSManagedObject) -> Bool) -> NSManagedObject? {
        for object in registeredObjects where !object.isFault {
            guard condition(object) else { continue }
            return object
        }
        return nil
    }
}

