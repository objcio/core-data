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
import CoreDataHelpers


public class Continent: NSManagedObject {

    @NSManaged public internal(set) var numberOfCountries: Int64
    @NSManaged public internal(set) var numberOfMoods: Int64
    @NSManaged public fileprivate(set) var countries: Set<Country>
    @NSManaged internal var updatedAt: Date

    public fileprivate(set) var iso3166Code: ISO3166.Continent {
        get {
            guard let c = ISO3166.Continent(rawValue: numericISO3166Code) else { fatalError("Unknown continent code") }
            return c
        }
        set {
            numericISO3166Code = newValue.rawValue
        }
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        primitiveUpdatedAt = Date()
    }

    static func findOrCreateContinent(for isoCountry: ISO3166.Country, in context: NSManagedObjectContext) -> Continent? {
        guard let iso3166 = ISO3166.Continent(country: isoCountry) else { return nil }
        let predicate = Continent.predicate(format: "%K == %d", #keyPath(numericISO3166Code), Int(iso3166.rawValue))
        let continent = findOrCreate(in: context, matching: predicate) { $0.iso3166Code = iso3166 }
        return continent
    }

    public override func willSave() {
        super.willSave()
        if hasChangedCountries {
            updateCountryCount()
            if countries.count == 0 {
                markForLocalDeletion()
            }
        }
        updateMoodCount()
    }

    func refreshUpdateDate() {
        guard changedValue(forKey: UpdateTimestampKey) == nil else { return }
        updatedAt = Date()
    }

    func updateMoodCount() {
        let currentAndDeletedCountries = countries.union(committedCountries)
        let deltaInCountries: Int64 = currentAndDeletedCountries.reduce(0) { $0 + $1.changedMoodCountDelta }
        let pendingDelta = numberOfMoods - committedNumberOfMoods
        guard pendingDelta != deltaInCountries else { return }
        numberOfMoods = committedNumberOfMoods + deltaInCountries
    }


    // MARK: Private

    @NSManaged fileprivate var numericISO3166Code: Int16
    @NSManaged fileprivate var primitiveUpdatedAt: Date

    fileprivate var hasChangedCountries: Bool {
        return changedValue(forKey: #keyPath(Continent.countries)) != nil
    }

    fileprivate func updateCountryCount() {
        guard numberOfCountries != Int64(countries.count) else { return }
        numberOfCountries = Int64(countries.count)
    }

    fileprivate var committedCountries: Set<Country> {
        return committedValue(forKey: #keyPath(Continent.countries)) as? Set<Country> ?? Set()
    }

    fileprivate var committedNumberOfMoods: Int64 {
        let n = committedValue(forKey: #keyPath(Continent.numberOfMoods)) as? Int ?? 0
        return Int64(n)
    }

    fileprivate var hasChangedNumberOfMoods: Bool {
        return changedValue(forKey: #keyPath(Continent.numberOfMoods)) != nil
    }

}


extension Continent: LocalizedStringConvertible {
    public var localizedDescription: String {
        return iso3166Code.localizedDescription
    }
}


extension Continent: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: UpdateTimestampKey, ascending: false)]
    }

    public static var defaultPredicate: NSPredicate {
        return notMarkedForLocalDeletionPredicate
    }
}


extension Continent: DelayedDeletable {
    @NSManaged public var markedForDeletionDate: Date?
}


extension Continent: UpdateTimestampable {}

