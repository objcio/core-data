//: [Previous](@previous)
//:
//: # Traversing Relationships

import UIKit
import CoreData


let model = citiesAndPeopleModel()
let moc = NSManagedObjectContext(model: model)
createCitiesAndPeopleInContext(moc)


//: ### To-One

do {
    let predicate = NSPredicate(format: "%K.%K > %lu", City.Keys.mayor.rawValue, Person.Keys.age.rawValue, 30)
    let n = moc.fetchCitiesMatchingPredicate(predicate).map(cityNameAndMayor)
}

//: ### To-Many with the `ANY` Keyword

do {
    let predicate = NSPredicate(format: "ANY %K.%K <= %lu", City.Keys.residents.rawValue, Person.Keys.age.rawValue, 20)
    let n = moc.fetchCitiesMatchingPredicate(predicate).map(cityNameAndResidents)
}

//: ### Subqueries

do {
    let predicate = NSPredicate(format: "(SUBQUERY(%K, $x, $x.%K >= %lu).@count == 0)", City.Keys.residents.rawValue, Person.Keys.age.rawValue, 36)
    let n = moc.fetchCitiesMatchingPredicate(predicate).map(cityNameAndResidents)
}

do {
    let predicate = NSPredicate(format: "(SUBQUERY(%K, $x, $x.%K < %lu).@count == %K.@count)", City.Keys.residents.rawValue, Person.Keys.age.rawValue, 36, City.Keys.residents.rawValue)
    let n = moc.fetchCitiesMatchingPredicate(predicate).map(cityNameAndResidents)
}

//: [Next](@next)
