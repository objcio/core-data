//
//  MoodsPresenter.swift
//  Moody
//
//  Created by Florian on 28/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData

protocol MoodsPresenter: class {
    var moodSource: MoodSource! { get set }
    var managedObjectContext: NSManagedObjectContext! { get set }
}


