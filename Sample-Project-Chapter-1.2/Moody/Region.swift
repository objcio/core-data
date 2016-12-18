//
//  Region.swift
//  Moody
//
//  Created by Florian on 03/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


final class Region: NSManagedObject {}

extension Region: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "updatedAt", ascending: false)]
    }
}

