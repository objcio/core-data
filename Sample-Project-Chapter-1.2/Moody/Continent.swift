//
//  Model.swift
//  Moody
//
//  Created by Florian on 07/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData


final class Continent: NSManagedObject {
    @NSManaged fileprivate(set) var countries: Set<Country>
    @NSManaged var updatedAt: Date

    fileprivate(set) var iso3166Code: ISO3166.Continent {
        get {
            guard let c = ISO3166.Continent(rawValue: numericISO3166Code) else { fatalError("Unknown continent code") }
            return c
        }
        set {
            numericISO3166Code = newValue.rawValue
        }
    }

    static func findOrCreateContinent(for isoCountry: ISO3166.Country, in context: NSManagedObjectContext) -> Continent? {
        guard let iso3166 = ISO3166.Continent(country: isoCountry) else { return nil }
        let predicate = NSPredicate(format: "%K == %d", #keyPath(numericISO3166Code), Int(iso3166.rawValue))
        let continent = findOrCreate(in: context, matching: predicate) {
            $0.iso3166Code = iso3166
            $0.updatedAt = Date()
        }
        return continent
    }


    // MARK: Private

    @NSManaged fileprivate var numericISO3166Code: Int16
}


extension Continent: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(updatedAt), ascending: false)]
    }
}

