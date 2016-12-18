//: [Previous](@previous)
//: # Format Strings
//:
//: Here are examples of how to use format strings with various values and value types.

import Foundation

//: #### Keys and Integers
//: Use `%K` for keys together with `#keyPath()`. Use `%lu` for `Int` values.

do {
    let a: Int = 25
    let predicate = NSPredicate(format: "%K == %ld", #keyPath(Person.age), a)
}

//: #### Floating Point Values
//: Use `%la` and `%a` for `Double` and `Float` values respectively.

do {
    let a: Double = 25.6789012345679
    let predicate = NSPredicate(format: "%K >= %la", #keyPath(Person.age), a)
}

do {
    let a: Float = 25.67891
    let predicate = NSPredicate(format: "%K <= %a", #keyPath(Person.age), a)
}

//: #### NSDate and NSNumber
//: Use the `%@` specifier.

do {
    let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    let predicate = NSPredicate(format: "%K < %@", #keyPath(Person.modificationDate), date as NSDate)
}

do {
    let age = NSNumber(value: 25)
    let predicate = NSPredicate(format: "%K == %@", #keyPath(Person.age), age)
}

//: #### Specifying a Range
//: Pass in an array with 2 values and use the `%@` specifier.

do {
    let predicate = NSPredicate(format: "%K BETWEEN %@", #keyPath(Person.age), [23, 28])
    predicate.predicateFormat
}

//: Alternatively pass the two objects directly.

do {
    let predicate = NSPredicate(format: "%K BETWEEN {%ld, %ld}", #keyPath(Person.age), 23, 28)
    predicate.predicateFormat
}

//: # Constant Values
//: Useful when implementing protocols.

protocol Hideable {
    static var hiddenPredicate: NSPredicate { get }
}

extension Person: Hideable {
    static var hiddenPredicate: NSPredicate {
        return NSPredicate(format: "%K", #keyPath(Person.hidden))
    }
}

extension City: Hideable {
    static var hiddenPredicate: NSPredicate {
        let predicate = NSPredicate(value: true)
        return predicate
    }
}


//: [Next](@next)

