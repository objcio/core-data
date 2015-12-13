//
//  ManagedObject.swift
//  Moody
//
//  Created by Florian on 29/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import CoreData


public class ManagedObject: NSManagedObject {
}


public protocol ManagedObjectType: class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    static var defaultPredicate: NSPredicate { get }
    var managedObjectContext: NSManagedObjectContext? { get }
}


public protocol DefaultManagedObjectType: ManagedObjectType {}

extension DefaultManagedObjectType {
    public static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
}


extension ManagedObjectType {

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }


    public static var sortedFetchRequest: NSFetchRequest {
        let request = NSFetchRequest(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        request.predicate = defaultPredicate
        return request
    }

    public static func sortedFetchRequestWithPredicate(predicate: NSPredicate) -> NSFetchRequest {
        let request = sortedFetchRequest
        guard let existingPredicate = request.predicate else { fatalError("must have predicate") }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, predicate])
        return request
    }

    public static func sortedFetchRequestWithPredicateFormat(format: String, args: CVarArgType...) -> NSFetchRequest {
        let predicate = withVaList(args) { NSPredicate(format: format, arguments: $0) }
        return sortedFetchRequestWithPredicate(predicate)
    }

    public static func predicateWithFormat(format: String, args: CVarArgType...) -> NSPredicate {
        let predicate = withVaList(args) { NSPredicate(format: format, arguments: $0) }
        return predicateWithPredicate(predicate)
    }

    public static func predicateWithPredicate(predicate: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [defaultPredicate, predicate])
    }

}


extension ManagedObjectType where Self: ManagedObject {

    public static func findOrCreateInContext(moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate, configure: Self -> ()) -> Self {
        guard let obj = findOrFetchInContext(moc, matchingPredicate: predicate) else {
            let newObject: Self = moc.insertObject()
            configure(newObject)
            return newObject
        }
        return obj
    }


    public static func findOrFetchInContext(moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self? {
        guard let obj = materializedObjectInContext(moc, matchingPredicate: predicate) else {
            return fetchInContext(moc) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
            }.first
        }
        return obj
    }

    public static func fetchInContext(context: NSManagedObjectContext, @noescape configurationBlock: NSFetchRequest -> () = { _ in }) -> [Self] {
        let request = NSFetchRequest(entityName: Self.entityName)
        configurationBlock(request)
        guard let result = try! context.executeFetchRequest(request) as? [Self] else { fatalError("Fetched objects have wrong type") }
        return result
    }

    public static func countInContext(context: NSManagedObjectContext, @noescape configurationBlock: NSFetchRequest -> () = { _ in }) -> Int {
        let request = NSFetchRequest(entityName: entityName)
        configurationBlock(request)
        var error: NSError?
        let result = context.countForFetchRequest(request, error: &error)
        guard result != NSNotFound else { fatalError("Failed to execute fetch request: \(error)") }
        return result
    }

    public static func materializedObjectInContext(moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self? {
        for obj in moc.registeredObjects where !obj.fault {
            guard let res = obj as? Self where predicate.evaluateWithObject(res) else { continue }
            return res
        }
        return nil
    }

}


extension ManagedObjectType where Self: ManagedObject {
    public static func fetchSingleObjectInContext(moc: NSManagedObjectContext, cacheKey: String, configure: NSFetchRequest -> ()) -> Self? {
        guard let cached = moc.objectForSingleObjectCacheKey(cacheKey) as? Self else {
            let result = fetchSingleObjectInContext(moc, configure: configure)
            moc.setObject(result, forSingleObjectCacheKey: cacheKey)
            return result
        }
        return cached
    }

    private static func fetchSingleObjectInContext(moc: NSManagedObjectContext, configure: NSFetchRequest -> ()) -> Self? {
        let result = fetchInContext(moc) { request in
            configure(request)
            request.fetchLimit = 2
        }
        switch result.count {
        case 0: return nil
        case 1: return result[0]
        default: fatalError("Returned multiple objects, expected max 1")
        }
    }
}

