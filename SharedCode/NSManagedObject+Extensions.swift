//
//  NSManagedObject+Extensions.swift
//  Moody
//
//  Created by Florian on 19/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


extension NSManagedObject {

    public func refresh(mergeChanges: Bool = true) {
        managedObjectContext?.refreshObject(self, mergeChanges: mergeChanges)
    }

}
