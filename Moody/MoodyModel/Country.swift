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


public final class Country: ManagedObject {

    @NSManaged private(set) var moods: Set<Mood>
    @NSManaged private(set) var continent: Continent?
    @NSManaged public internal(set) var numberOfMoods: Int64
    @NSManaged internal var updatedAt: NSDate

    public private(set) var iso3166Code: ISO3166.Country {
        get {
            guard let c = ISO3166.Country(rawValue: numericISO3166Code) else { fatalError("Unknown country code") }
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

    static func findOrCreateCountry(isoCountry: ISO3166.Country, inContext moc: NSManagedObjectContext) -> Country {
        // <<!strip>>
        let predicate___ = NSPredicate(format: "%K == %d",
            Keys.NumericISO3166Code.rawValue, Int(isoCountry.rawValue))
        predicate___
        // <<!/strip>>
        let predicate = Country.predicateWithPredicate(NSPredicate(format: "%K == %d", Keys.NumericISO3166Code.rawValue, Int(isoCountry.rawValue)))
        let country = findOrCreateInContext(moc, matchingPredicate: predicate) {
            $0.iso3166Code = isoCountry
            $0.continent = Continent.findOrCreateContinentForCountry(isoCountry, inContext: moc)
        }
        return country
    }

    public override func prepareForDeletion() {
        guard let c = continent else { return }
        if c.countries.filter({ !$0.deleted }).isEmpty {
            managedObjectContext?.deleteObject(c)
        }
    }

    public override func willSave() {
        super.willSave()
        if hasChangedMoods {
            updateMoodCount()
            if moods.count == 0 {
                markForLocalDeletion()
            }
        }
        if hasInsertedMoods {
            refreshUpdateDate()
        }
        if changedForDelayedDeletion {
            removeFromContinent()
        }
    }

    var changedMoodCountDelta: Int64 {
        guard hasChangedMoods else { return 0 }
        return numberOfMoods - committedNumberOfMoods
    }


    // MARK: Private
    @NSManaged private var numericISO3166Code: Int16
    @NSManaged private var primitiveUpdatedAt: NSDate


    private var hasChangedMoods: Bool {
        return changedValueForKey(Keys.Moods) != nil
    }

    private var hasInsertedMoods: Bool {
        guard hasChangedMoods else { return false }
        return moods.filter { $0.inserted }.count > 0
    }

    private var committedNumberOfMoods: Int64 {
        let n = committedValueForKey(Keys.NumberOfMoods) as? Int ?? 0
        return Int64(n)
    }

    private func refreshUpdateDate() {
        guard changedValues()[UpdateTimestampKey] == nil else { return }
        updatedAt = NSDate()
        continent?.refreshUpdateDate()
    }

    private func updateMoodCount() {
        guard Int64(moods.count) != numberOfMoods else { return }
        numberOfMoods = Int64(moods.count)
        continent?.updateMoodCount()
    }

    private func removeFromContinent() {
        guard continent != nil else { return }
        continent = nil
    }


}


extension Country: KeyCodable {
    public enum Keys: String {
        case Moods = "moods"
        case NumberOfMoods = "numberOfMoods"
        case NumericISO3166Code = "numericISO3166Code"
    }
}


extension Country: LocalizedStringConvertible {
    public var localizedDescription: String {
        return iso3166Code.localizedDescription
    }
}


extension Country: ManagedObjectType {
    public static var entityName: String {
        return "Country"
    }

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: UpdateTimestampKey, ascending: false)]
    }

    public static var defaultPredicate: NSPredicate {
        return notMarkedForLocalDeletionPredicate
    }
}


extension Country: DelayedDeletable {
    @NSManaged public var markedForDeletionDate: NSDate?
}


extension Country: UpdateTimestampable {}
