//: [Previous](@previous)
//: # Optional Values
//:
//: The `carsOwnedCount` property is optional, i.e. it can be `NULL` / `nil`. We can match on those values, too.
//: But note how the behaviour differs for direct comparison with `evaluateObject` and when using them on a fetch request.

import Foundation
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


extension NSPredicate {
    var carsOwnedCountForMatchingPeople: String {
        return allPeopleMatchingPredicate(self).map({ $0.carsOwnedCount?.description ?? "nil" }).joinWithSeparator(", ")
    }
    var carsOwnedCountForMatchingPeopleWithFetchRequest: String {
        let request = NSFetchRequest(entityName: Person.entityName)
        request.predicate = self
        let result = try! moc.executeFetchRequest(request) as! [Person]
        return result.map({ $0.carsOwnedCount?.description ?? "nil" }).joinWithSeparator(", ")
    }
}

do {
    let pA = NSPredicate(format: "%K == 1", Person.Keys.carsOwnedCount.rawValue)
    let cA = pA.carsOwnedCountForMatchingPeople

    let pB = NSPredicate(format: "%K >= 1", Person.Keys.carsOwnedCount.rawValue)
    let cB = pB.carsOwnedCountForMatchingPeople
    let cB2 = pB.carsOwnedCountForMatchingPeopleWithFetchRequest

    let pC = NSPredicate(format: "%K == nil", Person.Keys.carsOwnedCount.rawValue)
    let cC = pC.carsOwnedCountForMatchingPeople
    let cC2 = pC.carsOwnedCountForMatchingPeopleWithFetchRequest

    let pD = NSPredicate(format: "%K != 2", Person.Keys.carsOwnedCount.rawValue)
    let cD = pD.carsOwnedCountForMatchingPeople

    let cD2 = pD.carsOwnedCountForMatchingPeopleWithFetchRequest

    let pE = NSPredicate(format: "%K != 2 AND %K != nil", Person.Keys.carsOwnedCount.rawValue, Person.Keys.carsOwnedCount.rawValue)
    let cE = pE.carsOwnedCountForMatchingPeople
    let cE2 = pE.carsOwnedCountForMatchingPeopleWithFetchRequest

    let pF = NSPredicate(format: "%K != nil", Person.Keys.carsOwnedCount.rawValue)
    let cF = pF.carsOwnedCountForMatchingPeople
    let cF2 = pF.carsOwnedCountForMatchingPeopleWithFetchRequest
}

//: [Next](@next)
