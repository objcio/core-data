//
//  DataProvider.swift
//  Moody
//
//  Created by Florian on 08/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit


protocol DataProvider: class {
    associatedtype Object
    func objectAtIndexPath(indexPath: NSIndexPath) -> Object
    func numberOfItemsInSection(section: Int) -> Int
}


protocol DataProviderDelegate: class {
    associatedtype Object
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Object>]?)
}


enum DataProviderUpdate<Object> {
    case Insert(NSIndexPath)
    case Update(NSIndexPath, Object)
    case Move(NSIndexPath, NSIndexPath)
    case Delete(NSIndexPath)
}

