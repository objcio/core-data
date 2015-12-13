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
    case All
    case Yours(String?)
    case Country(MoodyModel.Country)
    case Continent(MoodyModel.Continent)
}


extension MoodSource {
    var predicate: NSPredicate {
        switch self  {
        case .All:
            return NSPredicate(value: true)
        case .Yours(let id):
            return Mood.predicateForOwnedByUserWithIdentifier(id)
        case .Country(let c):
            return NSPredicate(format: "country = %@", argumentArray: [c])
        case .Continent(let c):
            return NSPredicate(format: "country in %@", argumentArray: [c.countries])
        }
    }

    var managedObject: ManagedObjectType? {
        switch self {
        case .Country(let c): return c
        case .Continent(let c): return c
        default: return nil
        }
    }

    func prefetchInContext(context: NSManagedObjectContext) -> [MoodyModel.Country] {
        switch self {
        case .All: ()
            return MoodyModel.Country.fetchInContext(context) { request in
                request.predicate = MoodyModel.Country.defaultPredicate
            }
        case .Yours(let id):
            let yoursPredicate = MoodyModel.Country.predicateForContainingMoodsWithCreatorIdentifier(id)
            let predicate = MoodyModel.Country.predicateWithPredicate(yoursPredicate)
            return MoodyModel.Country.fetchInContext(context) { $0.predicate = predicate }
        case .Continent(let c):
            c.countries.fetchObjectsThatAreFaults()
            return Array(c.countries)
        default: return []
        }
    }
}


extension MoodSource: LocalizedStringConvertible {
    var localizedDescription: String {
        switch self  {
        case .All: return localized(.MoodSource_all)
        case .Yours: return localized(.MoodSource_your)
        case .Country(let c): return c.localizedDescription
        case .Continent(let c): return c.localizedDescription
        }
    }
}

