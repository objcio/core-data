import Foundation
import CoreData


// Moved some code here to make the playground faster / cleaner


extension SequenceType where Self.Generator.Element: AnyObject {
    @warn_unused_result
    public func filterWithPredicate(predicate: NSPredicate)  -> [Self.Generator.Element] {
        return filter { predicate.evaluateWithObject($0) }
    }
}

extension NSManagedObjectContext {
    public func fetchPeopleMatchingPredicate(predicate: NSPredicate) -> [Person] {
        let request = NSFetchRequest(entityName: Person.entityName)
        request.predicate = predicate
        return try! executeFetchRequest(request) as! [Person]
    }

    public func fetchCitiesMatchingPredicate(predicate: NSPredicate) -> [City] {
        let request = NSFetchRequest(entityName: City.entityName)
        request.predicate = predicate
        return try! executeFetchRequest(request) as! [City]
    }
}

public func personNameAndAge(p: Person) -> String {
    return "«\(p.name)», (\(p.age))"
}
public func personNameAndModificationDate(p: Person) -> String {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Day, .Hour, .Minute], fromDate: p.modificationDate, toDate: NSDate(), options: .WrapComponents)
    let formatter = NSDateComponentsFormatter()
    formatter.maximumUnitCount = 2
    formatter.formattingContext = .MiddleOfSentence
    let m = formatter.stringFromDateComponents(components)!
    return "«\(p.name)», modified \(m) ago"
}
public func cityNameAndMayor(c: City) -> String {
    return "'\(c.name)', mayor: \(personNameAndAge(c.mayor))"
}
public func cityNameAndResidents(c: City) -> String {
    let r = c.residents.map(personNameAndAge).joinWithSeparator(", ")
    return "'\(c.name)', \(c.residents.count) residents: \(r)"
}
