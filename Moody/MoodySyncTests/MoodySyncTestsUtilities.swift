//
//  MoodySyncTestsUtilities.swift
//  Moody
//
//  Created by Daniel Eggert on 23/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers


class TestObject: NSManagedObject, Managed {
    static var entityName: String { return "TestObject" }
    static var defaultSortDescriptors: [NSSortDescriptor] {
        get { return [NSSortDescriptor(key: "name", ascending: true)] }
    }
    static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
    @NSManaged var name: String?
}

class TestObjectB: NSManagedObject, Managed {
    static var entityName: String { return  "TestObjectB" }
    static var defaultSortDescriptors: [NSSortDescriptor] {
        get { return [NSSortDescriptor(key: "name", ascending: true)] }
    }
    static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
    @NSManaged var name: String?
}

var model: NSManagedObjectModel = {
    return NSManagedObjectModel() {
        let testObject = NSEntityDescription(cls: TestObject.self, name: TestObject.entityName)
        testObject.add(NSAttributeDescription.stringType(name: "name", defaultValue: "", propertyOptions: []))
        let testObjectB = NSEntityDescription(cls: TestObjectB.self, name: TestObjectB.entityName)
        testObjectB.add(NSAttributeDescription.stringType(name: "name", defaultValue: "", propertyOptions: []))
        return [testObject, testObjectB]
    }
}()


func createPersistentStoreCoordinatorWithInMemotyStore() -> NSPersistentStoreCoordinator {
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    try! psc.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    return psc
}

