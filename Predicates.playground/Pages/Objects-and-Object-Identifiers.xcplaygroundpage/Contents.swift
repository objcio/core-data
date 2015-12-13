//: [Previous](@previous)
//: # Objects and Object Identifiers
//:
//: We can match objects and their object identifiers directly, i.e. we can pass them into a predicate.


import UIKit
import CoreData


let model = citiesAndPeopleModel()
let moc = NSManagedObjectContext(model: model)
createCitiesAndPeopleInContext(moc)

let allPeople: [Person] = {
    let request = NSFetchRequest(entityName: Person.entityName)
    return try! moc.executeFetchRequest(request) as! [Person]
}()

//: ### Direct Matching

do {
    let person = allPeople.first!
    let request = NSFetchRequest(entityName: Person.entityName)
    request.predicate = NSPredicate(format: "self == %@", person)
    request.returnsObjectsAsFaults = false
    try! moc.executeFetchRequest(request)
}

do {
    let somePeople = Array(allPeople.prefix(5))
    let predicate = NSPredicate(format: "self IN %@", somePeople)
    let s = moc.fetchPeopleMatchingPredicate(predicate).map(personNameAndAge)
}

//: ### Through Relationships

do {
    let person = allPeople.first!.city.visitors.firstObject as! Person
    let predicate = NSPredicate(format: "%K CONTAINS %@", City.Keys.visitors.rawValue, person)
    let s = moc.fetchCitiesMatchingPredicate(predicate).map(cityNameAndMayor)
}

do {
    let person = allPeople.first!.city.visitors.firstObject as! Person
    let predicate = NSPredicate(format: "%K CONTAINS %@ AND %K.@count >= 3", City.Keys.visitors.rawValue, person, City.Keys.visitors.rawValue)
    let s = moc.fetchCitiesMatchingPredicate(predicate).map(cityNameAndMayor)
}


//: [Next](@next)
