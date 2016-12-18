//
//  Model.swift
//  Moody
//
//  Created by Florian on 07/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData


final class Mood: NSManagedObject {
    @NSManaged fileprivate(set) var date: Date
    @NSManaged fileprivate(set) var colors: [UIColor]

    static func insert(into context: NSManagedObjectContext, image: UIImage) -> Mood {
        let mood: Mood = context.insertObject()
        mood.colors = image.moodColors
        mood.date = Date()
        return mood
    }
}


extension Mood: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(date), ascending: false)]
    }
}


private let MaxColors = 8

extension UIImage {
    fileprivate var moodColors: [UIColor] {
        var colors: [UIColor] = []
        for c in dominantColors(.Moody) where colors.count < MaxColors {
            colors.append(c)
        }
        return colors
    }
}

