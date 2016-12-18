//: [Previous](@previous)
//: # Objects and Object Identifiers
//:
//: We can match objects and their object identifiers directly, i.e. we can pass them into a predicate.


import Foundation
import CoreData

let container = citiesAndPeopleModel().createContainerWithLoadedStores()
let moc = container.viewContext

createCitiesAndPeople(in: moc)

//: Some helper functions:

func randomPeople(count: Int) -> [Person] {
    let request = Person.sortedFetchRequest
    request.fetchLimit = count
    return try! moc.fetch(request)
}
var randomPerson: Person = {
    return randomPeople(count: 1).first!
}()

//: ### Direct Matching

do {
    let person = randomPerson
    let request = Person.sortedFetchRequest
    request.predicate = NSPredicate(format: "self == %@", person)
    request.returnsObjectsAsFaults = false
    _ = try! moc.fetch(request)
}

do {
    let somePeople = Array(randomPeople(count: 5))
    let predicate = NSPredicate(format: "self IN %@", somePeople)
    let s = try! moc.fetch(Person.sortedFetchRequest(with: predicate))
        .map{ $0.personNameAndAge }
    s
}

//: ### Through Relationships

do {
    let person = randomPerson.city.visitors.firstObject as! Person
    let predicate = NSPredicate(format: "%K CONTAINS %@", #keyPath(City.visitors), person)
    let s = try! moc.fetch(City.sortedFetchRequest(with: predicate))
        .map(cityNameAndMayor)
}

do {
    let person = randomPerson.city.visitors.firstObject as! Person
    let predicate = NSPredicate(format: "%K CONTAINS %@ AND %K.@count >= 3", #keyPath(City.visitors), person, #keyPath(City.visitors))
    let s = try! moc.fetch(City.sortedFetchRequest(with: predicate)) .map(cityNameAndMayor)
}


//: [Next](@next)

