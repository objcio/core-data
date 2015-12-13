//
//  MoodyMergePolicy.swift
//  Moody
//
//  Created by Florian on 25/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import CoreDataHelpers


public class MoodyMergePolicy: NSMergePolicy {
    public enum MergeMode {
        case Remote
        case Local

        private var mergeType: NSMergePolicyType {
            switch self {
            case .Remote: return .MergeByPropertyObjectTrumpMergePolicyType
            case .Local: return .MergeByPropertyStoreTrumpMergePolicyType
            }
        }
    }

    required public init(mode: MergeMode) {
        super.init(mergeType: mode.mergeType)
    }

    override public func resolveOptimisticLockingVersionConflicts(list: [NSMergeConflict]) throws {
        var regionsAndLatestDates: [(UpdateTimestampable, NSDate)] = []
        for (c, r) in list.conflictsAndObjectsWithType(UpdateTimestampable) {
            regionsAndLatestDates.append((r, c.newestUpdatedAt))
        }

        try super.resolveOptimisticLockingVersionConflicts(list)

        for (var region, date) in regionsAndLatestDates {
            region.updatedAt = date
        }

        resolveCountryConflicts(list)
        resolveContinentConflicts(list)
    }

    func resolveCountryConflicts(conflicts: [NSMergeConflict]) {
        for country in conflicts.conflictedObjectsWithType(Country) {
            country.refresh()
            country.numberOfMoods = Int64(country.moods.count)
        }
    }

    func resolveContinentConflicts(conflicts: [NSMergeConflict]) {
        for continent in conflicts.conflictedObjectsWithType(Continent) {
            continent.refresh()
            continent.numberOfCountries = Int64(continent.countries.count)
            guard let ctx = continent.managedObjectContext else { continue }
            let count = Mood.countInContext(ctx) { request in
                request.predicate = Mood.predicateWithFormat("country IN %@", args: continent.countries)
            }
            continent.numberOfMoods = Int64(count)
        }
    }

}


extension NSMergeConflict {
    var newestUpdatedAt: NSDate {
        guard let o = sourceObject as? UpdateTimestampable else { fatalError("must be UpdateTimestampable") }
        let key = UpdateTimestampKey
        let zeroDate = NSDate(timeIntervalSince1970: 0)
        let objectDate = objectSnapshot?[key] as? NSDate ?? zeroDate
        let cachedDate = cachedSnapshot?[key] as? NSDate ?? zeroDate
        let persistedDate = persistedSnapshot?[key] as? NSDate ?? zeroDate
        return max(o.updatedAt, max(objectDate, max(cachedDate, persistedDate)))
    }
}


extension SequenceType where Generator.Element == NSMergeConflict {
    func conflictedObjectsWithType<T>(cls: T.Type) -> [T] {
        return map { $0.sourceObject }.filterByType()
    }

    func conflictsAndObjectsWithType<T>(cls: T.Type) -> [(NSMergeConflict, T)] {
        return filter { $0.sourceObject is T }.map { ($0, $0.sourceObject as! T) }
    }
}


extension NSDate: Comparable {}

public func ==(l: NSDate, r: NSDate) -> Bool {
    return l.timeIntervalSince1970 == r.timeIntervalSince1970
}

public func <(l: NSDate, r: NSDate) -> Bool {
    return l.timeIntervalSince1970 < r.timeIntervalSince1970
}

