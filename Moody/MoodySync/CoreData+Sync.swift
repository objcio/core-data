//
//  CoreData+Sync.swift
//  Moody
//
//  Created by Daniel Eggert on 30/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


extension NSManagedObjectContext {
    func perform(group: DispatchGroup, block: @escaping () -> ()) {
        group.enter()
        perform {
            block()
            group.leave()
        }
    }
}


extension Sequence where Iterator.Element: NSManagedObject {
    func remap(to context: NSManagedObjectContext) -> [Iterator.Element] {
        return map { unmappedMO in
            guard unmappedMO.managedObjectContext !== context else { return unmappedMO }
            guard let object = context.object(with: unmappedMO.objectID) as? Iterator.Element else { fatalError("Invalid object type") }
            return object
        }
    }
}


extension NSManagedObjectContext {
    fileprivate var changedObjectsCount: Int {
        return insertedObjects.count + updatedObjects.count + deletedObjects.count
    }

    func delayedSaveOrRollback(group: DispatchGroup, completion: @escaping (Bool) -> () = { _ in }) {
        let changeCountLimit = 100
        guard changeCountLimit >= changedObjectsCount else { return completion(saveOrRollback()) }
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        group.notify(queue: queue) {
            self.perform(group: group) {
                guard self.hasChanges else { return completion(true) }
                completion(self.saveOrRollback())
            }
        }
    }
}

