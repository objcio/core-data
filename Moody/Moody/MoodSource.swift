//
//  MoodSource.swift
//  Moody
//
//  Created by Florian on 27/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import MoodyModel
import CoreData
import CoreDataHelpers

enum MoodSource {
    case all
    case yours(String?)
    case country(MoodyModel.Country)
    case continent(MoodyModel.Continent)
}


extension MoodSource {
    var predicate: NSPredicate {
        switch self  {
        case .all:
            return NSPredicate(value: true)
        case .yours(let id):
            return Mood.predicateForOwnedByUser(withIdentifier: id)
        case .country(let c):
            return NSPredicate(format: "country = %@", argumentArray: [c])
        case .continent(let c):
            return NSPredicate(format: "country in %@", argumentArray: [c.countries])
        }
    }

    var managedObject: NSManagedObject? {
        switch self {
        case .country(let c): return c
        case .continent(let c): return c
        default: return nil
        }
    }

    func prefetch(in context: NSManagedObjectContext) -> [MoodyModel.Country] {
        switch self {
        case .all:
            return MoodyModel.Country.fetch(in: context) { request in
                request.predicate = MoodyModel.Country.defaultPredicate
            }
        case .yours(let id):
            let yoursPredicate = MoodyModel.Country.predicateForContainingMoods(withCreatorIdentifier: id)
            let predicate = MoodyModel.Country.predicate(yoursPredicate)
            return MoodyModel.Country.fetch(in: context) { $0.predicate = predicate }
        case .continent(let c):
            c.countries.fetchFaults()
            return Array(c.countries)
        default: return []
        }
    }
}


extension MoodSource: LocalizedStringConvertible {
    var localizedDescription: String {
        switch self  {
        case .all: return localized(.moodSource_all)
        case .yours: return localized(.moodSource_your)
        case .country(let c): return c.localizedDescription
        case .continent(let c): return c.localizedDescription
        }
    }
}

