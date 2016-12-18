//: [Previous](@previous)
//: ## Combining Predicates
//:
//: We can combine predicates in two ways: Either directly within the format string, or by combining existing instances of `NSPredicate`.

import Foundation
import CoreData

let container = citiesAndPeopleModel().createContainerWithLoadedStores()
let moc = container.viewContext

createCitiesAndPeople(in: moc)


//: ### Format String
//: We can combine smaller predicates into more complex ones with `AND`, `OR`, and `NOT.

do {
    let predicateA = NSPredicate(format: "%K >= 30 AND %K < 32", #keyPath(Person.age), #keyPath(Person.age))
    let predicateB = NSPredicate(format: "%K == 30 OR %K == 31", #keyPath(Person.age), #keyPath(Person.age))
    let predicateC = NSPredicate(format: "NOT %K == 24", #keyPath(Person.age))
    let namesA = moc.fetchPeople(matching: predicateA).map { $0.personNameAndAge }
    let namesB = moc.fetchPeople(matching: predicateB).map { $0.personNameAndAge }
    let namesC = moc.fetchPeople(matching: predicateC).map { $0.personNameAndAge }
}

//: ### NSCompoundPredicate
//: We can use `NSCompoundPredicate` to combine predicates in code. This lets us construct predicates from smaller pieces while re-using existing code — hence avoiding duplication.

extension Person {
    static var isRecentlyModifiedPredicate: NSPredicate {
        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return NSPredicate(format: "%K < %@", #keyPath(Person.modificationDate), date as NSDate)
    }
    static var isMayorPredicate: NSPredicate {
        return NSPredicate(format: "%K != nil", #keyPath(Person.mayorOf))
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

//: We can negate predicates in code.

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

