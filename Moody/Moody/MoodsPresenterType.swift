//
//  MoodsPresenterType.swift
//  Moody
//
//  Created by Florian on 28/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//


protocol MoodsPresenterType: ManagedObjectContextSettable {
    var moodSource: MoodSource! { get set }
}

