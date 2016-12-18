import Foundation
import CoreData


// Moved some code here to make the playground faster / cleaner


extension Sequence where Self.Iterator.Element: AnyObject {

    public func filter(with predicate: NSPredicate)  -> [Self.Iterator.Element] {
        return filter { predicate.evaluate(with: $0) }
    }
}

extension NSManagedObjectContext {
    public func fetchPeople(matching predicate: NSPredicate) -> [Person] {
        let request = Person.sortedFetchRequest(with: predicate)
        return try! fetch(request)
    }

    public func fetchCities(matching predicate: NSPredicate) -> [City] {
        let request = City.sortedFetchRequest(with: predicate)
        return try! fetch(request)
    }
}

extension Person {
    public var personNameAndAge: String {
        return "«\(self.name)», (\(self.age))"
    }
}
public func personNameAndModificationDate(p: Person) -> String {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day, .hour, .minute], from: p.modificationDate, to: Date())
    let formatter = DateComponentsFormatter()
    formatter.maximumUnitCount = 2
    formatter.formattingContext = .middleOfSentence
    let m = formatter.string(from: components) ?? ""
    return "«\(p.name)», modified \(m) ago"
}
public func cityNameAndMayor(c: City) -> String {
    return "'\(c.name)', mayor: \(c.mayor.personNameAndAge)"
}
public func cityNameAndResidents(c: City) -> String {
    let r = c.residents.map { $0.personNameAndAge }.joined(separator: ", ")
    return "'\(c.name)', \(c.residents.count) residents: \(r)"
}


/// Create a container and synchronously load its stores.
///
/// - Note: Should not do this in production code, but it's great for Playgrounds.
public extension NSManagedObjectModel {
    public func createContainerWithLoadedStores(databaseName: String = "myStore.db") -> NSPersistentContainer {
        let container = NSPersistentContainer(model: self, databaseName: databaseName)
        container.deleteStoresAndSynchronouslyLoadStores()
        return container
    }
}

extension NSPersistentContainer {
    public convenience init(model: NSManagedObjectModel, databaseName: String) {
        self.init(name: "Playground", managedObjectModel: model)
        let storeURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(databaseName)!
        let store = NSPersistentStoreDescription(url: storeURL)
        persistentStoreDescriptions = [store]
    }
}

private extension NSPersistentContainer {
    /// Playground specific helper
    func deleteStoresAndSynchronouslyLoadStores() {
        let g = DispatchGroup()
        let q = DispatchQueue.global()
        q.async(group: g) {
            self.deleteStores(group: g)
            self.loadStores(group: g)
        }

        guard g.wait(wallTimeout: DispatchWallTime.distantFuture) == .success else {
            fatalError("Failed waiting for stores to load.")
        }
    }
    /// Playground specific helper
    func deleteStores(group: DispatchGroup) {
        group.enter()
        persistentStoreCoordinator.perform {
            for s in self.persistentStoreDescriptions {
                try! self.persistentStoreCoordinator.destroyPersistentStore(at: s.url!, ofType: s.type, options: s.options)
            }
            group.leave()
        }
    }
    /// Playground specific helper
    func loadStores(group: DispatchGroup) {
        for _ in persistentStoreDescriptions {
            group.enter()
        }
        loadPersistentStores { (_, e) in
            if let error = e {
                print("Error loading store: \(error)")
            }
            group.leave()
        }
    }
}

