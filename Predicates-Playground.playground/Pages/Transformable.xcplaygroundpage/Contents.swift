//: [Previous](@previous)
//: ## Transformable Attributes
//:
//: The `City` entity has a propery called `remoteIdentifier` that is an optional `NSUUID`.
//: It's implemented as a transformable attribute with a custom `NSValueTransformer`. We can still use predicates on this attribute.

import Foundation
import CoreData

let container = citiesAndPeopleModel().createContainerWithLoadedStores()
let moc = container.viewContext

createCitiesAndPeople(in: moc)

//: Here’s a helper method to print out the results.

extension NSPredicate {
    var matchingCityNameAndRemoteIdentifier: [String] {
        let people = moc.fetchCities(matching: self)
        return people.map {
            let u = $0.remoteIdentifier?.uuidString ?? ""
            return "\($0.name) \(u)"
        }
    }
}

//: We’ll fetch some random `remoteIdentifier` from the database. We can then use this one for our examples.

let someRemoteIdentifier: NSUUID = {
    let request = City.sortedFetchRequest(with: NSPredicate(format: "%K != NULL", #keyPath(City.remoteIdentifier)))
    request.fetchLimit = 1
    let city = try! moc.fetch(request).first!
    return city.remoteIdentifier!
}()

//: ### Exact Matches
//:
//: If we use `==` this will get translated to a binary match query in SQLite.

do {
    let identifier: NSUUID = someRemoteIdentifier
    let predicate = NSPredicate(format: "%K == %@", #keyPath(City.remoteIdentifier), identifier)
    let s = predicate.matchingCityNameAndRemoteIdentifier
}

//: ### Inequalities
//:
//: If we can also use `<` and `>` — these are also done on the binary bytes that the transformation outputs.

do {
    let identifier: NSUUID = someRemoteIdentifier
    let s1 = identifier.uuidString
    let predicate = NSPredicate(format: "%K < %@", #keyPath(City.remoteIdentifier), identifier)
    let s2 = predicate.matchingCityNameAndRemoteIdentifier
}


//: [Next](@next)
//

