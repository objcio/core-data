//: [Previous](@previous)
//: ## Constructing in Code
//:
//: We can build an `NSPredicate` entirely in code using `NSExpression` and `NSComparisonPredicate`.
//: The normal approach using a format string is easier to read, but sometimes we need something more dynamic.

import Foundation
import CoreData

let container = citiesAndPeopleModel().createContainerWithLoadedStores()
let moc = container.viewContext

createCitiesAndPeople(in: moc)


do {
    let predicate = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: #keyPath(Person.age)), rightExpression: NSExpression(forConstantValue: 32), modifier: .direct, type: .equalTo, options: [])
    let s = predicate.predicateFormat
    let result = moc.fetchPeople(matching: predicate).map{ $0.personNameAndAge }
    result
}


//: [Next](@next)

