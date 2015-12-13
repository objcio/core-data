//: [Previous](@previous)
//: # Transformable Attributes
//:
//: The `City` entity has a propery called `remoteIdentifier` that is an optional `NSUUID`.
//: It's implemented as a transformable attribute with a custom `NSValueTransformer`. We can still use predicates on this attribute.

import UIKit
import CoreData


let model = citiesAndPeopleModel()
let moc = NSManagedObjectContext(model: model)
createCitiesAndPeopleInContext(moc)

func allCitiesMatchingPredicate(predicate: NSPredicate) -> [City] {
    let request = NSFetchRequest(entityName: City.entityName)
    request.predicate = predicate
    return try! moc.executeFetchRequest(request) as! [City]
}

extension NSPredicate {
    var matchingCityNameAndRemoteIdentifier: [String] {
        let people = allCitiesMatchingPredicate(self)
        return people.map {
            let u = $0.remoteIdentifier?.UUIDString ?? ""
            return "\($0.name) \(u)"
        }
    }
}

let allCities = try! moc.executeFetchRequest(NSFetchRequest(entityName: City.entityName)) as! [City]
let allRemoteIdentifiers = allCities.flatMap { $0.remoteIdentifier }

do {
    let identifier: NSUUID = allRemoteIdentifiers.first!
    let predicate = NSPredicate(format: "%K == %@", City.Keys.remoteIdentifier.rawValue, identifier)
    let s = predicate.matchingCityNameAndRemoteIdentifier
}

do {
    let identifier: NSUUID = allRemoteIdentifiers.first!
    let s1 = identifier.UUIDString
    let predicate = NSPredicate(format: "%K < %@", City.Keys.remoteIdentifier.rawValue, identifier)
    let s2 = predicate.matchingCityNameAndRemoteIdentifier
}


//: [Next](@next)
//
