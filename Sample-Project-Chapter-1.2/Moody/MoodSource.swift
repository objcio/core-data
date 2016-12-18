//
//  MoodSource.swift
//  Moody
//
//  Created by Florian on 27/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData

enum MoodSource {
    case country(Country)
    case continent(Continent)
}


extension MoodSource {
    init(region: NSManagedObject) {
        if let country = region as? Country {
            self = .country(country)
        } else if let continent = region as? Continent {
            self = .continent(continent)
        } else {
            fatalError("\(region) is not a valid mood source")
        }
    }

    var predicate: NSPredicate {
        switch self  {
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
        }
    }
}


extension MoodSource: LocalizedStringConvertible {
    var localizedDescription: String {
        switch self  {
        case .country(let c): return c.localizedDescription
        case .continent(let c): return c.localizedDescription
        }
    }
}

