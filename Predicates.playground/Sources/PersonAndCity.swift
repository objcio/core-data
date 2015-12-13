import Foundation
import CoreData


public final class City: ManagedObject {
    public static let entityName = "City"
    public enum Keys: String {
        case name
        case mayor
        case residents
        case visitors
        case remoteIdentifier
    }
    @NSManaged public var name: String
    @NSManaged public var mayor: Person
    @NSManaged public var remoteIdentifier: NSUUID?
    @NSManaged public var residents: Set<Person>
    @NSManaged public var visitors: NSOrderedSet
}


public class Person: ManagedObject {
    public static let entityName = "Person"
    public enum Keys: String {
        case givenName
        case familyName
        case age
        case carsOwnedCount
        case modificationDate
        case hidden
        case city
        case mayorOf
        case visitedCities
    }

    @NSManaged public var givenName: String
    @NSManaged public var familyName: String
    @NSManaged public var age: Int16
    @NSManaged public var carsOwnedCount: NSNumber?
    @NSManaged public var modificationDate: NSDate
    @NSManaged public var hidden: Bool
    @NSManaged public var city: City
    @NSManaged public var mayorOf: City?
    @NSManaged public var visitedCities: Set<City>
}


let personNameFormatter: NSPersonNameComponentsFormatter = {
    let f = NSPersonNameComponentsFormatter()
    return f
    }()

extension Person {
    var nameComponents: NSPersonNameComponents {
        let c = NSPersonNameComponents()
        c.givenName = givenName
        c.familyName = familyName
        return c
    }
    public var name: String {
        return personNameFormatter.stringFromPersonNameComponents(nameComponents)
    }
    public override var description: String {
        return "\(name), \(age)"
    }
}
extension Person: CustomDebugStringConvertible {
    public override var debugDescription: String {
        if fault {
            return "Person \(objectID)"
        } else {
            return "Person \(objectID) name: '\(name)' age: \(age)"
        }
    }
}

public func citiesAndPeopleModel() -> NSManagedObjectModel {
    return NSManagedObjectModel() {
        let person = NSEntityDescription(cls: Person.self, name: Person.entityName)
        person.addProperty(NSAttributeDescription.stringType(Person.Keys.givenName.rawValue, optional: false))
        person.addProperty(NSAttributeDescription.stringType(Person.Keys.familyName.rawValue, optional: false))
        person.addProperty(NSAttributeDescription.int16Type(Person.Keys.age.rawValue, optional: false))
        person.addProperty(NSAttributeDescription.int16Type(Person.Keys.carsOwnedCount.rawValue, optional: true))
        person.addProperty(NSAttributeDescription.dateType(Person.Keys.modificationDate.rawValue, optional: false))
        person.addProperty(NSAttributeDescription.boolType(Person.Keys.hidden.rawValue, defaultValue: false, indexed: true, optional: false))

        let remoteIDTransform = DataTransform<NSUUID?>(name: "RemoteIdentifier", forward: { (uuid: NSUUID?) -> NSData? in
            guard let uuid = uuid else { return nil }
            let uuidBytes = UnsafeMutablePointer<UInt8>.alloc(16)
            uuid.getUUIDBytes(uuidBytes)
            return NSData(bytes: uuidBytes, length: 16)
        }, reverse: { (data: NSData?) -> NSUUID? in
            guard let data = data where data.length == 16 else { return nil }
            let uuidBytes = UnsafeMutablePointer<UInt8>.alloc(16)
            data.getBytes(uuidBytes, length: 16)
            return NSUUID(UUIDBytes: uuidBytes)
        })

        let city = NSEntityDescription(cls: City.self, name: City.entityName)
        city.addProperty(NSAttributeDescription.stringType(City.Keys.name.rawValue, optional: false, indexed: true))
        city.addProperty(NSAttributeDescription.transformableType(City.Keys.remoteIdentifier.rawValue, transform: remoteIDTransform))

        city.createOneToManyRelationTo(person, toName: City.Keys.residents.rawValue, fromName: Person.Keys.city.rawValue)
        city.createOneToOneRelationTo(person, toName: City.Keys.mayor.rawValue, fromName: Person.Keys.mayorOf.rawValue)
        city.createManyToOrderedManyRelationTo(person, toName: City.Keys.visitors.rawValue, fromName: Person.Keys.visitedCities.rawValue)

        return [person, city]
    }
}

//
// MARK: Stack
//


private let cityNames = ["New York", "Los Angeles", "Chicago", "Houston", "Philadelphia", "Phoenix", "San Antonio", "San Diego", "Dallas", "San Jose", "Austin", "Jacksonville", "San Francisco", "Indianapolis", "Columbus", "Fort Worth", "Charlotte", "Detroit", "El Paso", "Seattle", "Denver", "Washington", "Memphis", "Boston", "Nashville", "Baltimore", "Oklahoma City", "Portland", "Las Vegas", "Louisville", "Milwaukee", "Albuquerque", "Tucson", "Fresno", "Sacramento", "Long Beach", "Kansas City", "Mesa", "Atlanta", "Virginia Beach", "Omaha", "Colorado Springs", "Raleigh", "Miami", "Oakland", "Minneapolis", "Tulsa", "Cleveland", "Wichita", "New Orleans"]

public func createCitiesAndPeopleInContext(moc: NSManagedObjectContext) {
    var allCities: [City] = []
    var allPeople: [Person] = []
    for name in cityNames {
        let city = NSEntityDescription.insertNewObjectForEntityForName(City.entityName, inManagedObjectContext: moc) as! City
        allCities.append(city)
        city.name = name
        switch arc4random_uniform(3) {
        case 0:
            city.remoteIdentifier = nil
        default:
            city.remoteIdentifier = NSUUID()
        }

        let numberOfResidents = 8 + arc4random_uniform(4)
        for _ in 0..<numberOfResidents {
            let person = NSEntityDescription.insertNewObjectForEntityForName(Person.entityName, inManagedObjectContext: moc) as! Person
            allPeople.append(person)
            person.givenName = randomGivenName()
            person.familyName = randomFamilyName()
            person.age = Int16(20 + arc4random_uniform(20))
            person.city = city
            switch arc4random_uniform(4) {
            case 0:
                person.carsOwnedCount = nil
            case 1:
                person.carsOwnedCount = 0
            case 2:
                person.carsOwnedCount = 1
            default:
                person.carsOwnedCount = 2
            }
            person.modificationDate = NSDate(timeIntervalSinceNow: -NSTimeInterval(arc4random_uniform(260_000)))
        }
        city.mayor = city.residents.first!
    }
    for city in allCities {
        let visitors = NSMutableOrderedSet()
        let count = 2 + arc4random_uniform(4)
        for _ in 0..<count {
            visitors.addObject(allPeople.randomElement)
        }
        city.visitors = visitors
    }
    try! moc.save()
}
