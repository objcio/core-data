//
//  NSFetchRequest+Extensions.swift
//  Moody
//
//  Created by Florian on 29/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import CoreData


extension NSFetchRequest {

    convenience init(entity: NSEntityDescription, predicate: NSPredicate? = nil, batchSize: Int = 0) {
        self.init()
        self.entity = entity
        self.predicate = predicate
        self.fetchBatchSize = batchSize
    }

}


