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


public final class Continent: ManagedObject {

    @NSManaged public internal(set) var numberOfCountries: Int64
    @NSManaged public internal(set) var numberOfMoods: Int64
    @NSManaged public private(set) var countries: Set<Country>
    @NSManaged internal var updatedAt: NSDate

    public private(set) var iso3166Code: ISO3166.Continent {
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
        primitiveUpdatedAt = NSDate()
    }

    static func findOrCreateContinentForCountry(isoCountry: ISO3166.Country, inContext moc: NSManagedObjectContext) -> Continent? {
        guard let iso3166 = ISO3166.Continent.fromCountry(isoCountry) else { return nil }
        // <<!strip>>
        let predicate___ = NSPredicate(format: "%K == %d",
            Keys.NumericISO3166Code.rawValue, Int(iso3166.rawValue))
        predicate___
        // <<!/strip>>
        let predicate = Continent.predicateWithPredicate(NSPredicate(format: "%K == %d", Keys.NumericISO3166Code.rawValue, Int(iso3166.rawValue)))
        let continent = findOrCreateInContext(moc, matchingPredicate: predicate) { $0.iso3166Code = iso3166 }
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
        guard changedValues()[UpdateTimestampKey] == nil else { return }
        updatedAt = NSDate()
    }

    func updateMoodCount() {
        let currentAndDeletedCountries = countries.union(committedCountries)
        let deltaInCountries: Int64 = currentAndDeletedCountries.reduce(0) { $0 + $1.changedMoodCountDelta }
        let pendingDelta = numberOfMoods - committedNumberOfMoods
        guard pendingDelta != deltaInCountries else { return }
        numberOfMoods = committedNumberOfMoods + deltaInCountries
    }


    // MARK: Private

    @NSManaged private var numericISO3166Code: Int16
    @NSManaged private var primitiveUpdatedAt: NSDate

    private var hasChangedCountries: Bool {
        return changedValueForKey(Keys.Countries) != nil
    }

    private func updateCountryCount() {
        guard numberOfCountries != Int64(countries.count) else { return }
        numberOfCountries = Int64(countries.count)
    }

    private var committedCountries: Set<Country> {
        return committedValueForKey(Keys.Countries) as? Set<Country> ?? Set()
    }

    private var committedNumberOfMoods: Int64 {
        let n = committedValueForKey(Keys.NumberOfMoods) as? Int ?? 0
        return Int64(n)
    }

    private var hasChangedNumberOfMoods: Bool {
        return changedValues()["numberOfMoods"] != nil
    }

}


extension Continent: KeyCodable {
    public enum Keys: String {
        case Countries = "countries"
        case NumberOfMoods = "numberOfMoods"
        case NumericISO3166Code = "numericISO3166Code"
    }
}


extension Continent: LocalizedStringConvertible {
    public var localizedDescription: String {
        return iso3166Code.localizedDescription
    }
}


extension Continent: ManagedObjectType {
    public static var entityName: String {
        return "Continent"
    }

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: UpdateTimestampKey, ascending: false)]
    }

    public static var defaultPredicate: NSPredicate {
        return notMarkedForLocalDeletionPredicate
    }
}


extension Continent: DelayedDeletable {
    @NSManaged public var markedForDeletionDate: NSDate?
}


extension Continent: UpdateTimestampable {}
