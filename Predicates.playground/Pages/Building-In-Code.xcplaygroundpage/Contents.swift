//: [Previous](@previous)
//: # Constructing in Code
//:
//: We can build an `NSPredicate` entirely in code using `NSExpression` and `NSComparisonPredicate`.
//: The normal approach using a format string is easier to read, but sometimes we need something more dynamic.

import Foundation
import UIKit
import CoreData


let model = citiesAndPeopleModel()
let moc = NSManagedObjectContext(model: model)
createCitiesAndPeopleInContext(moc)


do {
    let predicate = NSComparisonPredicate(
        leftExpression: NSExpression(forKeyPath: Person.Keys.age.rawValue),
        rightExpression: NSExpression(forConstantValue: 32),
        modifier: .DirectPredicateModifier,
        type: NSPredicateOperatorType.EqualToPredicateOperatorType,
        options: [])
    let s = predicate.predicateFormat
    let r = moc.fetchPeopleMatchingPredicate(predicate).map(personNameAndAge)
}


//: [Next](@next)
