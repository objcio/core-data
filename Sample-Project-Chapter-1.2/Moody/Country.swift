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


final class Country: NSManagedObject {
    @NSManaged fileprivate(set) var moods: Set<Mood>
    @NSManaged fileprivate(set) var continent: Continent?
    @NSManaged var updatedAt: Date

    fileprivate(set) var iso3166Code: ISO3166.Country {
        get {
            guard let c = ISO3166.Country(rawValue: numericISO3166Code) else { fatalError("Unknown country code") }
            return c
        }
        set {
            numericISO3166Code = newValue.rawValue
        }
    }

    static func findOrCreate(for isoCountry: ISO3166.Country, in context: NSManagedObjectContext) -> Country {
        let predicate = NSPredicate(format: "%K == %d", #keyPath(numericISO3166Code), Int(isoCountry.rawValue))
        let country = findOrCreate(in: context, matching: predicate) {
            $0.iso3166Code = isoCountry
            $0.updatedAt = Date()
            $0.continent = Continent.findOrCreateContinent(for: isoCountry, in: context)
        }
        return country
    }

    override func prepareForDeletion() {
        guard let c = continent else { return }
        if c.countries.filter({ !$0.isDeleted }).isEmpty {
            managedObjectContext?.delete(c)
        }
    }


    // MARK: Private

    @NSManaged fileprivate var numericISO3166Code: Int16
}


extension Country: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(updatedAt), ascending: false)]
    }
}

