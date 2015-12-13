//
//  CoreData+Sync.swift
//  Moody
//
//  Created by Daniel Eggert on 30/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


extension NSManagedObjectContext {
    func performBlockWithGroup(group: dispatch_group_t, block: () -> ()) {
        dispatch_group_enter(group)
        performBlock {
            block()
            dispatch_group_leave(group)
        }
    }
}


extension SequenceType where Generator.Element: NSManagedObject {
    func remapToContext(context: NSManagedObjectContext) -> [Generator.Element] {
        return map { unmappedMO in
            guard unmappedMO.managedObjectContext !== context else { return unmappedMO }
            guard let object = context.objectWithID(unmappedMO.objectID) as? Generator.Element else { fatalError("Invalid object type") }
            return object
        }
    }
}


extension NSManagedObjectContext {
    private var changedObjectsCount: Int {
        return insertedObjects.count + updatedObjects.count + deletedObjects.count
    }

    func delayedSaveOrRollbackWithGroup(group: dispatch_group_t, completion: (Bool) -> () = { _ in }) {
        let changeCountLimit = 100
        guard changeCountLimit >= changedObjectsCount else { return completion(saveOrRollback()) }
        let queue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)
        dispatch_group_notify(group, queue) {
            self.performBlockWithGroup(group) {
                guard self.hasChanges else { return completion(true) }
                completion(self.saveOrRollback())
            }
        }
    }
}
