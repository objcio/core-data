//: [Previous](@previous)
//: # Text and Strings
//: Matching text that is visible to the user is described in the chapter about “Text” — it's a quite complex topic.
//:
//: Here we look at how to match text that is *not* visible to the user. In this example, the text that we're trying to match is a country code, e.g. `CAN` for Canada.
//:
//: Note how we pass the `[n]` option to the comparison operators to specify that these strings can be compared byte for byte.

import Foundation
import CoreData


let model = countryModel()
let moc = NSManagedObjectContext(model: model)
createCountriesInContext(moc)


func allCitiesMatchingPredicate(predicate: NSPredicate) -> [Country] {
    let request = NSFetchRequest(entityName: Country.entityName)
    request.predicate = predicate
    return try! moc.executeFetchRequest(request) as! [Country]
}

func descriptionsForCitiesMatchingPredicate(predicate: NSPredicate) -> [String] {
    return allCitiesMatchingPredicate(predicate).map({ $0.description })
}

do {
    let predicate = NSPredicate(format: "%K ==[n] %@", Country.Keys.alpha3Code.rawValue, "ZAF")
    let m = descriptionsForCitiesMatchingPredicate(predicate)
}

do {
    let predicate = NSPredicate(format: "%K BEGINSWITH[n] %@", Country.Keys.alpha3Code.rawValue, "CA")
    let m = descriptionsForCitiesMatchingPredicate(predicate)
}

do {
    let predicate = NSPredicate(format: "%K ENDSWITH[n] %@", Country.Keys.alpha3Code.rawValue, "K")
    let m = descriptionsForCitiesMatchingPredicate(predicate)
}

do {
    let predicate = NSPredicate(format: "%K CONTAINS[n] %@", Country.Keys.alpha3Code.rawValue, "IN")
    let m = descriptionsForCitiesMatchingPredicate(predicate)
}


do {
    let predicate = NSPredicate(format: "%K LIKE[n] %@", Country.Keys.alpha3Code.rawValue, "?A?")
    let m = descriptionsForCitiesMatchingPredicate(predicate)
}

do {
    let predicate = NSPredicate(format: "%K MATCHES[n] %@", Country.Keys.alpha3Code.rawValue, "[AB][FLH](.)")
    let m = descriptionsForCitiesMatchingPredicate(predicate)
}

do {
    let predicate = NSPredicate(format: "%K IN[n] %@", Country.Keys.alpha3Code.rawValue, ["FRA", "FIN", "ISL"])
    let m = descriptionsForCitiesMatchingPredicate(predicate)
}


//: [Next](@next)
