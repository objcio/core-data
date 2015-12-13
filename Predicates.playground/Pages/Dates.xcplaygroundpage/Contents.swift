//: [Previous](@previous)
//: # Dates (NSDate)
//:
//: Dates are represented by `NSDate` instances, which are objects that wrap a double precision floating point number.
//: They work very similar to numbers, but we have to use the `%@` format specifier instead of `%ld`.


import Foundation
import UIKit
import CoreData


let model = citiesAndPeopleModel()
let moc = NSManagedObjectContext(model: model)
createCitiesAndPeopleInContext(moc)

extension NSPredicate {
    var namesAndModificationDatesForMatchingPeople: String {
        return moc.fetchPeopleMatchingPredicate(self).map({
            "'\($0.name) \($0.modificationDate.description)'"
        }).joinWithSeparator(", ")
    }
}

do {
    let date = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: .WrapComponents) ?? NSDate()
    let predicate = NSPredicate(format: "%K < %@", Person.Keys.modificationDate.rawValue, date)
    let matches = moc.fetchPeopleMatchingPredicate(predicate).map(personNameAndModificationDate)
}

do {
    let minusTwoDays = NSDateComponents()
    minusTwoDays.day = -2
    let plusDay = NSDateComponents()
    plusDay.day = 1
    let startDate = NSCalendar.currentCalendar().dateByAddingComponents(minusTwoDays, toDate: NSDate(), options: .WrapComponents) ?? NSDate()
    let endDate = NSCalendar.currentCalendar().dateByAddingComponents(plusDay, toDate: startDate, options: .WrapComponents) ?? NSDate()
    let predicate = NSPredicate(format: "%@ < %K && %K < %@",
        startDate, Person.Keys.modificationDate.rawValue,
        Person.Keys.modificationDate.rawValue, endDate)
    let matches = moc.fetchPeopleMatchingPredicate(predicate).map(personNameAndModificationDate)
}

// date between {$YESTERDAY, $TOMORROW}
do {
    let minusTwoDays = NSDateComponents()
    minusTwoDays.day = -2
    let plusDay = NSDateComponents()
    plusDay.day = 1
    let startDate = NSCalendar.currentCalendar().dateByAddingComponents(minusTwoDays, toDate: NSDate(), options: .WrapComponents) ?? NSDate()
    let endDate = NSCalendar.currentCalendar().dateByAddingComponents(plusDay, toDate: startDate, options: .WrapComponents) ?? NSDate()
    let predicate = NSPredicate(format: "%K BETWEEN {%@, %@}", Person.Keys.modificationDate.rawValue, startDate, endDate)
    let matches = moc.fetchPeopleMatchingPredicate(predicate).map(personNameAndModificationDate)
}


//: [Next](@next)
