//: [Previous](@previous)
//: # Format Strings
//:
//: Here are examples of how to use format strings with various values and value types.

import Foundation

//: #### Keys and Integers
//: Use `%K` for keys (and key paths). Use `%lu` for `Int` values.

do {
    let a: Int = 25
    let predicate = NSPredicate(format: "%K == %ld", Person.Keys.age.rawValue, a)
}

//: #### Floating Point Values
//: Use `%la` and `%a` for `Double` and `Float` values respectively.

do {
    let a: Double = 25.6789012345679
    let predicate = NSPredicate(format: "%K >= %la", Person.Keys.age.rawValue, a)
}

do {
    let a: Float = 25.67891
    let predicate = NSPredicate(format: "%K <= %a", Person.Keys.age.rawValue, a)
}

//: #### NSDate and NSNumber
//: Use the `%@` specifier.

do {
    let day = NSDateComponents()
    day.hour = -1
    let date = NSCalendar.currentCalendar().dateByAddingComponents(day, toDate: NSDate(), options: .WrapComponents) ?? NSDate()
    let predicate = NSPredicate(format: "%K < %@", Person.Keys.modificationDate.rawValue, date)
}

do {
    let age = NSNumber(integer: 25)
    let predicate = NSPredicate(format: "%K == %@", Person.Keys.age.rawValue, age)
}

//: #### Specifying a Range
//: Pass in an array with 2 values and use the `%@` specifier.

do {
    let predicate = NSPredicate(format: "%K BETWEEN %@", Person.Keys.age.rawValue, [23, 28]).predicateFormat
}

//: Alternatively pass the two objects directly.

do {
    let predicate = NSPredicate(format: "%K BETWEEN {%ld, %ld}", Person.Keys.age.rawValue, 23, 28).predicateFormat
}

//: # Constant Values
//: Useful when implementing protocols.

protocol Hideable {
    static var hiddenPredicate: NSPredicate { get }
}

extension Person: Hideable {
    static var hiddenPredicate: NSPredicate {
        return NSPredicate(format: "%K", Person.Keys.hidden.rawValue)
    }
}

extension City: Hideable {
    static var hiddenPredicate: NSPredicate {
        let predicate = NSPredicate(value: true)
        return predicate
    }
}


//: [Next](@next)
