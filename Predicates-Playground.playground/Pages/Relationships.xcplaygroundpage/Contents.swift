//: [Previous](@previous)
//:
//: ## Traversing Relationships
//:
//: Relationships are a very perwerful aspect of Core Data.
//: Here are some examples how predicates and relationships work together.

import Foundation
import CoreData

let container = citiesAndPeopleModel().createContainerWithLoadedStores()
let moc = container.viewContext

createCitiesAndPeople(in: moc)


//: ### To-One
//:
//: We use `%K` with `#keyPath` to specify a relationship.
//: For a *to-one* relationship, we can extend this by using `%K.%K` and two
//: `#keyPath` — one for the key of the object we're fetching, and one for the key
//: of the relationship.

do {
    let predicate = NSPredicate(format: "%K.%K > %lu", #keyPath(City.mayor), #keyPath(Person.age), 30)
    let n = moc.fetchCities(matching: predicate).map(cityNameAndMayor)
}

//: ### To-Many with the `ANY` Keyword
//:
//: Predicates with *to-many* relationships potentially have multiple objects as the result of
//: the key path. Hence we need to specify how we want to match, e.g. by adding `ANY`.

do {
    let predicate = NSPredicate(format: "ANY %K.%K <= %lu", #keyPath(City.residents), #keyPath(Person.age), 20)
    let n = moc.fetchCities(matching: predicate).map(cityNameAndResidents)
}

//: ### Subqueries
//:
//: For more complex logig, we can use `SUBQUERT` predicates.
//:
//: In this example, we're matching cities in which no residents are 36 or older.

do {
    let predicate = NSPredicate(format: "(SUBQUERY(%K, $x, $x.%K >= %lu).@count == 0)", #keyPath(City.residents), #keyPath(Person.age), 36)
    predicate.description
    let n = moc.fetchCities(matching: predicate).map(cityNameAndResidents)
}

//:
//: Alternatively, we could have implemented that predicate like this. We're matching cities in which all residents are younger than 36.

do {
    let predicate = NSPredicate(format: "(SUBQUERY(%K, $x, $x.%K < %lu).@count == %K.@count)", #keyPath(City.residents), #keyPath(Person.age), 36, #keyPath(City.residents))
    predicate.description
    let n = moc.fetchCities(matching: predicate).map(cityNameAndResidents)
}

//: [Next](@next)

