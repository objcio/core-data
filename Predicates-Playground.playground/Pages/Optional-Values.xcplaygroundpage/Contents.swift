//: [Previous](@previous)
//: # Optional Values
//:
//: The `carsOwnedCount` property is optional, i.e. it can be `NULL` / `nil`. We can match on those values, too.
//: But note how the behaviour differs for direct comparison with `evaluateObject` and when using them on a fetch request.

import Foundation
import CoreData

let container = citiesAndPeopleModel().createContainerWithLoadedStores()
let moc = container.viewContext

createCitiesAndPeople(in: moc)

//: We fetch all `City` and `Person` object into memory to show how predicates behave on *in-memory* objects.

let allCities = try! moc.fetch(City.sortedFetchRequest)
let allPeople = try! moc.fetch(Person.sortedFetchRequest)

func inMemoryPeople(matching predicate: NSPredicate) -> [Person] {
    return allPeople.filter{ predicate.evaluate(with: $0) }
}
func inMemoryCities(matching predicate: NSPredicate) -> [City] {
    return allCities.filter{ predicate.evaluate(with: $0) }
}


extension NSPredicate {
    var carsOwnedCountForMatchingPeople: String {
        let result = inMemoryPeople(matching: self)
        return "[\(result.count)]: " +
            result
                .map({ $0.carsOwnedCount?.description ?? "nil" })
                .joined(separator: ", ")
    }
    var carsOwnedCountForMatchingPeopleWithFetchRequest: String {
        let request = Person.sortedFetchRequest(with: self)
        let result = try! moc.fetch(request)
        return "[\(result.count)]: " +
            result
                .map({ $0.carsOwnedCount?.description ?? "nil" })
                .joined(separator: ", ")
    }
}

do {
    let pA = NSPredicate(format: "%K == 1", #keyPath(Person.carsOwnedCount))
    let cA = pA.carsOwnedCountForMatchingPeople

    let pB = NSPredicate(format: "%K >= 1", #keyPath(Person.carsOwnedCount))
    let cB = pB.carsOwnedCountForMatchingPeople
    let cB2 = pB.carsOwnedCountForMatchingPeopleWithFetchRequest

    let pC = NSPredicate(format: "%K == nil", #keyPath(Person.carsOwnedCount))
    let cC = pC.carsOwnedCountForMatchingPeople
    let cC2 = pC.carsOwnedCountForMatchingPeopleWithFetchRequest

    let pD = NSPredicate(format: "%K != 2", #keyPath(Person.carsOwnedCount))
    let cD = pD.carsOwnedCountForMatchingPeople
    let cD2 = pD.carsOwnedCountForMatchingPeopleWithFetchRequest

    let pE = NSPredicate(format: "%K != 2 AND %K != nil", #keyPath(Person.carsOwnedCount), #keyPath(Person.carsOwnedCount))
    let cE = pE.carsOwnedCountForMatchingPeople
    let cE2 = pE.carsOwnedCountForMatchingPeopleWithFetchRequest

    let pF = NSPredicate(format: "%K != nil", #keyPath(Person.carsOwnedCount))
    let cF = pF.carsOwnedCountForMatchingPeople
    let cF2 = pF.carsOwnedCountForMatchingPeopleWithFetchRequest
}

//: [Next](@next)

