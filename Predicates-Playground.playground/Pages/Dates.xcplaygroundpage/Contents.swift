//: [Previous](@previous)
//: ## Dates (NSDate)
//:
//: Dates are represented by `Date` or `NSDate` instances. They wrap a double precision floating point number.
//: They work very similar to numbers.


import Foundation
import CoreData

let container = citiesAndPeopleModel().createContainerWithLoadedStores()
let moc = container.viewContext

createCitiesAndPeople(in: moc)

extension Calendar {
    func daysFromNow(_ days: Int) -> Date {
        return date(byAdding: .day, value: days, to: Date()) ?? Date()
    }
}

//: We can pass `Date` instances into predicates to match dates that are before or after a specific date.
//: The only thing we need to do is to convert / cast it to `NSDate`. Core Data will automatically
//: use the date’s *time stamp since reference date* to ensure that SQLite can compare dates efficiently.


do {
    let date = Calendar.current.daysFromNow(-1)
    let predicate = NSPredicate(format: "%K < %@", #keyPath(Person.modificationDate), date as NSDate)
    let matches = moc.fetchPeople(matching: predicate).map(personNameAndModificationDate)
}

//: If we want to check if a date is in a range, we can either
//: (1) manually create a range check with `"%@ < %K && %K < %@"`
//: …

do {
    let startDate = Calendar.current.daysFromNow(-2)
    let endDate = Calendar.current.daysFromNow(1)
    let predicate = NSPredicate(format: "%@ < %K && %K < %@",
        startDate as NSDate, #keyPath(Person.modificationDate),
        #keyPath(Person.modificationDate), endDate as NSDate)
    let matches = moc.fetchPeople(matching: predicate).map(personNameAndModificationDate)
}

//: … or (2) use `"%K BETWEEN {%@, %@}"`

do {
    let startDate = Calendar.current.daysFromNow(-1)
    let endDate = Calendar.current.daysFromNow(1)
    let predicate = NSPredicate(format: "%K BETWEEN {%@, %@}", #keyPath(Person.modificationDate), startDate as NSDate, endDate as NSDate)
    let matches = moc.fetchPeople(matching: predicate).map(personNameAndModificationDate)
}


//: [Next](@next)

