//
//  Mood+Remote.swift
//  Moody
//
//  Created by Daniel Eggert on 22/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import MoodyModel
import CoreData


extension RemoteMood {
    func insertIntoContext(context: NSManagedObjectContext) -> Mood? {
        let mood = Mood.insertIntoContext(context, colors: colors, location: location, isoCountry: isoCountry, remoteIdentifier: id, date: date, creatorID: creatorID)
        return mood
    }
}


extension Mood: RemoteUploadable {}
