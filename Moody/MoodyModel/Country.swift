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


public class Country: NSManagedObject {

    @NSManaged fileprivate(set) var moods: Set<Mood>
    @NSManaged fileprivate(set) var continent: Continent?
    @NSManaged public internal(set) var numberOfMoods: Int64
    @NSManaged internal var updatedAt: Date

    public fileprivate(set) var iso3166Code: ISO3166.Country {
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
        primitiveUpdatedAt = Date()
    }

    static func findOrCreate(for isoCountry: ISO3166.Country, in context: NSManagedObjectContext) -> Country {
        let predicate = Country.predicate(format: "%K == %d", #keyPath(numericISO3166Code), Int(isoCountry.rawValue))
        let country = findOrCreate(in: context, matching: predicate) {
            $0.iso3166Code = isoCountry
            $0.continent = Continent.findOrCreateContinent(for: isoCountry, in: context)
        }
        return country
    }

    public override func prepareForDeletion() {
        guard let c = continent else { return }
        if c.countries.filter({ !$0.isDeleted }).isEmpty {
            managedObjectContext?.delete(c)
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
    @NSManaged fileprivate var numericISO3166Code: Int16
    @NSManaged fileprivate var primitiveUpdatedAt: Date


    fileprivate var hasChangedMoods: Bool {
        return changedValue(forKey: #keyPath(moods)) != nil
    }

    fileprivate var hasInsertedMoods: Bool {
        guard hasChangedMoods else { return false }
        return moods.filter { $0.isInserted }.count > 0
    }

    fileprivate var committedNumberOfMoods: Int64 {
        let n = committedValue(forKey: #keyPath(numberOfMoods)) as? Int ?? 0
        return Int64(n)
    }

    fileprivate func refreshUpdateDate() {
        guard changedValue(forKey: UpdateTimestampKey) == nil else { return }
        updatedAt = Date()
        continent?.refreshUpdateDate()
    }

    fileprivate func updateMoodCount() {
        guard Int64(moods.count) != numberOfMoods else { return }
        numberOfMoods = Int64(moods.count)
        continent?.updateMoodCount()
    }

    fileprivate func removeFromContinent() {
        guard continent != nil else { return }
        continent = nil
    }


}


extension Country: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: UpdateTimestampKey, ascending: false)]
    }

    public static var defaultPredicate: NSPredicate {
        return notMarkedForLocalDeletionPredicate
    }
}

extension Country: DelayedDeletable {
    @NSManaged public var markedForDeletionDate: Date?
}

extension Country: UpdateTimestampable {}

