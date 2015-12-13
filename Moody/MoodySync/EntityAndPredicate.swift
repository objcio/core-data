//
//  EntityAndPredicate.swift
//  Moody
//
//  Created by Daniel Eggert on 23/08/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import Foundation
import CoreData


struct EntityAndPredicate {
    let entity: NSEntityDescription
    let predicate: NSPredicate
}


extension EntityAndPredicate {
    var fetchRequest: NSFetchRequest {
        let request = NSFetchRequest()
        request.entity = entity
        request.predicate = predicate
        return request
    }
}


extension EntityAndPredicate {
    init(entityName: String, predicate: NSPredicate, context: ChangeProcessorContextType) {
        self.init(entityName: entityName, predicate: predicate, context: context.managedObjectContext)
    }

    init(entityName: String, predicate: NSPredicate, context: NSManagedObjectContext) {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else { fatalError("No model?") }
        guard let entity = model.entitiesByName[entityName] else { fatalError("Model has no entity named '\(entityName)'") }
        self.init(entity: entity, predicate: predicate)
    }
}


extension SequenceType where Generator.Element: NSManagedObject {
    func objectsMatching(entityAndPredicate: EntityAndPredicate) -> [Generator.Element] {
        typealias MO = Generator.Element
        let filtered = filter { (mo: Generator.Element) -> Bool in
            guard mo.entity === entityAndPredicate.entity else { return false }
            return entityAndPredicate.predicate.evaluateWithObject(mo)
        }
        return Array(filtered)
    }
}
