//: # Predicates
//:
//: Demo of using `NSPredicate` with Core Data.
//:
//: Predicates let us filter objects. We can either specify a predicate on a fetch request or match objects directly.


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

//: ## Using Predicates
//:
//: ### Direct Evaluation
//: The `evaluateWithObject(_:)` method lets us match an object directly.

do {
    let person = allPeople.first!
    let predicate = NSPredicate(format: "age == 32")
    if predicate.evaluateWithObject(person) {
        print("\(person.name) is 32 years old")
    } else {
        print("\(person.name) is younger or older than 32 years")
    }
}

//: ### Fetch Request
//: Fetch requests have a `predicate` property that we can set an `NSPredicate` on to limit the result to matching objects.

do {
    let request = NSFetchRequest(entityName: Person.entityName)
    request.fetchLimit = 1
    request.predicate = NSPredicate(format: "age == 32")
    let result = try! moc.executeFetchRequest(request) as! [Person]
    if let person = result.first {
        print("\(person.name) is \(person.age) years old")
    }
}

//: ## Simple Examples

//: The most straightforward approach is to use a format string.

do {
    let predicate = NSPredicate(format: "age == 32")
    let names = moc.fetchPeopleMatchingPredicate(predicate).map(personNameAndAge)
}

//: But we should not hardcode *keys* / *attribute names* inside format strings. Instead, by using the `%K` format specifier, we can have the compiler help us avoid typos in attribute names, and make it easier for us to later change attribute names.

do {
    let predicate = NSPredicate(format: "%K == 32", Person.Keys.age.rawValue)
    let names = moc.fetchPeopleMatchingPredicate(predicate).map(personNameAndAge)
}

//: Also constant values can be moved outside the format string itself.

do {
    let predicate = NSPredicate(format: "%K < %ld", Person.Keys.age.rawValue, 32)
    let names = moc.fetchPeopleMatchingPredicate(predicate).map(personNameAndAge)
}

//: There are various different comparison operators.

do {
    let predicateA = NSPredicate(format: "%K <= 30", Person.Keys.age.rawValue)
    let predicateB = NSPredicate(format: "%K > 30", Person.Keys.age.rawValue)
    let predicateC = NSPredicate(format: "%K != 24", Person.Keys.age.rawValue)
    let namesA = moc.fetchPeopleMatchingPredicate(predicateA).map(personNameAndAge)
    let namesB = moc.fetchPeopleMatchingPredicate(predicateB).map(personNameAndAge)
    let namesC = moc.fetchPeopleMatchingPredicate(predicateC).map(personNameAndAge)
}

//: ## Matching Multiple Values
//: We can match multiple values with the `IN` operator.

do {
    let primeNumbers = [13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    let predicate = NSPredicate(format: "%K IN %@", Person.Keys.age.rawValue, primeNumbers)
    let names = moc.fetchPeopleMatchingPredicate(predicate).map(personNameAndAge)
}

//: [Next](@next)

