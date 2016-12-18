//: # Predicates
//:
//: ## Using `NSPredicate` with Core Data.
//:
//: Predicates let us filter objects. We can either specify a predicate on a fetch request or match objects directly.
//:
//:
//:
//: ### Book
//:
//: This Playround is part of objc.io’s [Core Data Book](https://www.objc.io/books/core-data/).


//: ### Setup
//:
//: This Playground uses `Person` and `City` classes and corresponding entities to show how predicates can be used.
//: These are all defined in the `PersonAndCity.swift` file. Additionally this Playground uses some of the *shared code* used throughout the book.
//:
//: We create a persistent container with a simple model. And we use the `viewContext` for all samples.
import Foundation
import CoreData

let container = citiesAndPeopleModel().createContainerWithLoadedStores()
let context = container.viewContext

createCitiesAndPeople(in: context)

//: The following implements *in-memory* filtering (of `Person` and `City`).
//: This is usually **not** what you want to do, but we use it in this Playground
//: to illustrate some predicate related aspects.


//: ## Introduction
//:
//: ### Direct Evaluation
//: The `evaluateWithObject(_:)` method lets us match an object directly.

do {
    let request = Person.sortedFetchRequest
    request.fetchLimit = 1
    let person = try! context.fetch(request).first!
    let predicate = NSPredicate(format: "age == 32")
    if predicate.evaluate(with: person) {
        print("\(person.name) is 32 years old")
    } else {
        print("\(person.name) is not 32 years")
    }
}

//: ### Fetch Request
//: Fetch requests have a `predicate` property that we can set an `NSPredicate` on to limit the result to matching objects.

do {
    let request = NSFetchRequest<Person>()
    request.entity = Person.entity()
    request.fetchLimit = 1
    request.predicate = NSPredicate(format: "age == 32")
    let result = try! context.fetch(request)
    if let person = result.first {
        print("\(person.name) is \(person.age) years old")
    }
}

//: ## Simple Examples
//:
//: When creating a predicate,
//: the most straightforward approach is to use a format string.

do {
    let predicate = NSPredicate(format: "age == 32")
    let names = context.fetchPeople(matching: predicate).map{ $0.personNameAndAge }
    names
}

//: But we should not hardcode *keys* / *attribute names* inside format strings. Instead it is better to use the `%K` format specifier and pass the key (or key path) as an argument with `#keyPath()`. With this the compiler help us to avoid typos in attribute names. And it makes easier for us to later change attribute names.

do {
    let predicate = NSPredicate(format: "%K == 32", #keyPath(Person.age))
    let names = context.fetchPeople(matching: predicate).map{ $0.personNameAndAge }
    names
}

//: Likewise constant values can be moved outside the format string itself.

do {
    let predicate = NSPredicate(format: "%K < %ld", #keyPath(Person.age), 32)
    let names = context.fetchPeople(matching: predicate).map{ $0.personNameAndAge }
}

//: There are various different comparison operators.

do {
    let predicateA = NSPredicate(format: "%K <= 30", #keyPath(Person.age))
    let predicateB = NSPredicate(format: "%K > 30", #keyPath(Person.age))
    let predicateC = NSPredicate(format: "%K != 24", #keyPath(Person.age))
    let namesA = context.fetchPeople(matching: predicateA).map{ $0.personNameAndAge }
    namesA
    let namesB = context.fetchPeople(matching: predicateB).map{ $0.personNameAndAge }
    namesB
    let namesC = context.fetchPeople(matching: predicateC).map{ $0.personNameAndAge }
    namesC
}

//: ## Matching Multiple Values
//: We can match multiple values with the `IN` operator.

do {
    let primeNumbers = [13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    let predicate = NSPredicate(format: "%K IN %@", #keyPath(Person.age), primeNumbers)
    let names = context.fetchPeople(matching: predicate).map{ $0.personNameAndAge }
    names
}


//: [Next](@next)

