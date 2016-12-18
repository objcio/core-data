import Foundation
import CoreData


public final class City: NSManagedObject, Managed {
    @NSManaged public var name: String
    @NSManaged public var mayor: Person
    @NSManaged public var remoteIdentifier: NSUUID?
    @NSManaged public var residents: Set<Person>
    @NSManaged public var visitors: NSOrderedSet
}


public class Person: NSManagedObject, Managed {
    @NSManaged public var givenName: String
    @NSManaged public var familyName: String
    @NSManaged public var age: Int16
    @NSManaged public var carsOwnedCount: NSNumber?
    @NSManaged public var modificationDate: Date
    @NSManaged public var hidden: Bool
    @NSManaged public var city: City
    @NSManaged public var mayorOf: City?
    @NSManaged public var visitedCities: Set<City>
}


let personNameFormatter: PersonNameComponentsFormatter = {
    let f = PersonNameComponentsFormatter()
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
        return personNameFormatter.string(from: nameComponents as PersonNameComponents)
    }
    public override var description: String {
        return "\(name), \(age)"
    }
    public override var debugDescription: String {
        return super.description
    }
}

public func citiesAndPeopleModel() -> NSManagedObjectModel {
    return NSManagedObjectModel(builder: {
        let person = NSEntityDescription(cls: Person.self, name: "Person")
        person.add(NSAttributeDescription.stringType(name: #keyPath(Person.givenName), propertyOptions: []))
        person.add(NSAttributeDescription.stringType(name: #keyPath(Person.familyName), propertyOptions: []))
        person.add(NSAttributeDescription.int16Type(name: #keyPath(Person.age), propertyOptions: []))
        person.add(NSAttributeDescription.int16Type(name: #keyPath(Person.carsOwnedCount), propertyOptions: [.optional]))
        person.add(NSAttributeDescription.dateType(name: #keyPath(Person.modificationDate), propertyOptions: []))
        person.add(NSAttributeDescription.boolType(name: #keyPath(Person.hidden), defaultValue: false, propertyOptions: [.indexed]))

        let remoteIDTransform = DataTransform<NSUUID?>(name: "RemoteIdentifier", forward: { (uuid: NSUUID?) -> NSData? in
            guard let uuid = uuid else { return nil }
            let uuidBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
            uuid.getBytes(uuidBytes)
            return NSData(bytes: uuidBytes, length: 16)
        }, reverse: { (data: NSData?) -> NSUUID? in
            guard let data = data , data.length == 16 else { return nil }
            let uuidBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
            data.getBytes(uuidBytes, length: 16)
            return NSUUID(uuidBytes: uuidBytes)
        })

        let city = NSEntityDescription(cls: City.self, name: "City")
        city.add(NSAttributeDescription.stringType(name: #keyPath(City.name), propertyOptions: [.indexed]))
        city.add(NSAttributeDescription.transformableType(name: #keyPath(City.remoteIdentifier), transform: remoteIDTransform))

        city.createOneToManyRelation(to: person, toName: #keyPath(City.residents), fromName: #keyPath(Person.city))
        city.createOneToOneRelation(to: person, toName: #keyPath(City.mayor), fromName: #keyPath(Person.mayorOf))

        city.createManyToOrderedManyRelation(to: person, toName: #keyPath(City.visitors), fromName: #keyPath(Person.visitedCities))

        return [person, city]
    })
}

//
// MARK: Stack
//


private let cityNames = ["New York", "Los Angeles", "Chicago", "Houston", "Philadelphia", "Phoenix", "San Antonio", "San Diego", "Dallas", "San Jose", "Austin", "Jacksonville", "San Francisco", "Indianapolis", "Columbus", "Fort Worth", "Charlotte", "Detroit", "El Paso", "Seattle", "Denver", "Washington", "Memphis", "Boston", "Nashville", "Baltimore", "Oklahoma City", "Portland", "Las Vegas", "Louisville", "Milwaukee", "Albuquerque", "Tucson", "Fresno", "Sacramento", "Long Beach", "Kansas City", "Mesa", "Atlanta", "Virginia Beach", "Omaha", "Colorado Springs", "Raleigh", "Miami", "Oakland", "Minneapolis", "Tulsa", "Cleveland", "Wichita", "New Orleans"]

public func createCitiesAndPeople(in moc: NSManagedObjectContext) {
    var allCities: [City] = []
    var allPeople: [Person] = []
    for name in cityNames {
        let city = NSEntityDescription.insertNewObject(forEntityName: City.entity().name!, into: moc) as! City
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
            let person = NSEntityDescription.insertNewObject(forEntityName: Person.entity().name!, into: moc) as! Person
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
            person.modificationDate = Date(timeIntervalSinceNow: -TimeInterval(arc4random_uniform(260_000)))
        }
        city.mayor = city.residents.first!
    }
    for city in allCities {
        let visitors = NSMutableOrderedSet()
        let count = 2 + arc4random_uniform(4)
        for _ in 0..<count {
            visitors.add(allPeople.randomElement)
        }
        city.visitors = visitors
    }
    try! moc.save()
}

