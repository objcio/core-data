//
//  UpdateTimestampable.swift
//  Moody
//
//  Created by Florian on 25/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//


let UpdateTimestampKey = "updatedAt"

protocol UpdateTimestampable: class {
    var updatedAt: Date { get set }
}

