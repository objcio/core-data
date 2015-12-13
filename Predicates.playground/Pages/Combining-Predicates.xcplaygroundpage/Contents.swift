//: [Previous](@previous)
//: # Combining Predicates
//:
//: We can combine predicates in two ways: Either directly within the format string, or by combining existing instances of `NSPredicate`.

import Foundation
import UIKit
import CoreData


let model = citiesAndPeopleModel()
let moc = NSManagedObjectContext(model: model)
createCitiesAndPeopleInContext(moc)


let allCities = try! moc.executeFetchRequest(NSFetchRequest(entityName: City.entityName)) as! [City]
let allPeople = try! moc.executeFetchRequest(NSFetchRequest(entityName: Person.entityName)) as! [Person]

func allPeopleMatchingPredicate(predicate: NSPredicate) -> [Person] {
    return allPeople.filterWithPredicate(predicate)
}
func allCitiesMatchingPredicate(predicate: NSPredicate) -> [City] {
    return allCities.filterWithPredicate(predicate)
}

//: ## Format String
//: We can combine smaller predicates into more complex ones with `AND`, `OR`, and `NOT.

do {
    let predicateA = NSPredicate(format: "%K >= 30 AND %K < 32", Person.Keys.age.rawValue, Person.Keys.age.rawValue)
    let predicateB = NSPredicate(format: "%K == 30 OR %K == 31", Person.Keys.age.rawValue, Person.Keys.age.rawValue)
    let predicateC = NSPredicate(format: "NOT %K == 24", Person.Keys.age.rawValue)
    let namesA = allPeopleMatchingPredicate(predicateA).map(personNameAndAge)
    let namesB = allPeopleMatchingPredicate(predicateB).map(personNameAndAge)
    let namesC = allPeopleMatchingPredicate(predicateC).map(personNameAndAge)
}

//: ### NSCompoundPredicate
//: We can use `NSCompoundPredicate` to combine predicates in code. This lets us construct predicates from smaller pieces while re-using existing code — hence avoiding duplication.

extension Person {
    static var isRecentlyModifiedPredicate: NSPredicate {
        let date = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: .WrapComponents) ?? NSDate()
        return NSPredicate(format: "%K < %@", Person.Keys.modificationDate.rawValue, date)
    }
    static var isMayorPredicate: NSPredicate {
        return NSPredicate(format: "%K != nil", Person.Keys.mayorOf.rawValue)
    }
}

extension Person {
    static var isMayorAndRecentlyModifiedPredicate: NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [Person.isRecentlyModifiedPredicate, Person.isMayorPredicate])
    }
    static var isMayorOrRecentlyModifiedPredicate: NSPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: [Person.isRecentlyModifiedPredicate, Person.isMayorPredicate])
    }
}

extension Person {
    static var notMayorPredicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: Person.isMayorPredicate)
    }
}

//: The combined predicates now look like this:

do {
    let formatA = Person.isRecentlyModifiedPredicate.predicateFormat
    let formatB = Person.isMayorPredicate.predicateFormat
    let formatC = Person.isMayorAndRecentlyModifiedPredicate.predicateFormat
    let formatD = Person.isMayorOrRecentlyModifiedPredicate.predicateFormat
}
//: [Next](@next)
