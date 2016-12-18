//: [Previous](@previous)
//: ## Text and Strings
//:
//: Matching text that is visible to the user is described in the chapter about *Text* — it's a quite complex topic.
//:
//: Here we look at how to match text that is *not* visible to the user. In this example, the text that we're trying to match is a country code, e.g. `CAN` for Canada.
//:
//: Note how we pass the `[n]` option to the comparison operators to specify that these strings can be compared byte for byte.

import Foundation
import CoreData


let container = countryModel().createContainerWithLoadedStores(databaseName: "countries.db")
let moc = container.viewContext

createCountries(in: moc)


func allCountries(matching predicate: NSPredicate) -> [Country] {
    let request = Country.sortedFetchRequest(with: predicate)
    return try! moc.fetch(request)
}

func descriptionsForCountries(matching predicate: NSPredicate) -> [String] {
    return allCountries(matching: predicate).map({ $0.description })
}


do {
    let predicate = NSPredicate(format: "%K ==[n] %@", #keyPath(Country.alpha3Code), "ZAF")
    let m = descriptionsForCountries(matching: predicate)
}

do {
    let predicate = NSPredicate(format: "%K BEGINSWITH[n] %@", #keyPath(Country.alpha3Code), "CA")
    let m = descriptionsForCountries(matching: predicate)
}

do {
    let predicate = NSPredicate(format: "%K ENDSWITH[n] %@", #keyPath(Country.alpha3Code), "K")
    let m = descriptionsForCountries(matching: predicate)
}

do {
    let predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(Country.alpha3Code), "IN")
    let m = descriptionsForCountries(matching: predicate)
}


do {
    let predicate = NSPredicate(format: "%K LIKE[n] %@", #keyPath(Country.alpha3Code), "?A?")
    let m = descriptionsForCountries(matching: predicate)
}

do {
    let predicate = NSPredicate(format: "%K MATCHES[n] %@", #keyPath(Country.alpha3Code), "[AB][FLH](.)")
    let m = descriptionsForCountries(matching: predicate)
}

do {
    let predicate = NSPredicate(format: "%K IN[n] %@", #keyPath(Country.alpha3Code), ["FRA", "FIN", "ISL"])
    let m = descriptionsForCountries(matching: predicate)
}


//: [Next](@next)

