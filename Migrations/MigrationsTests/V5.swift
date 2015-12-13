//
//  V5.swift
//  Migrations
//
//  Created by Florian on 03/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import UIKit
@testable import Migrations


private struct MoodV5: TestEntityDataType {
    let entityName = "Mood"
    let markedForRemoteDeletion: Bool
    let country: CountryV5?
    let date: NSDate
    let latitude: Double?
    let longitude: Double?
    let markedForDeletionDate: NSDate?
    let creatorID: String?
    let remoteID: String?
    let colors: [UIColor]
    let rating: Int

    init(markedForRemoteDeletion: Bool, country: CountryV5?, date: NSDate, latitude: Double, longitude: Double, markedForDeletionDate: NSDate?, creatorID: String?, remoteID: String?, colors: NSData, rating: Int) {
        self.markedForRemoteDeletion = markedForRemoteDeletion
        self.country = country
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.markedForDeletionDate = markedForDeletionDate
        self.creatorID = creatorID
        self.remoteID = remoteID
        self.colors = colors.moodColors!
        self.rating = rating
    }

    func matchesManagedObject(mo: NSManagedObject) -> Bool {
        guard mo.entity.name == "Mood",
            let markedForRemoteDeletion = mo.valueForKey("markedForRemoteDeletion") as? Bool,
            let date = mo.valueForKey("date") as? NSDate,
            let colors = mo.valueForKey("colors") as? [UIColor],
            let rating = mo.valueForKey("rating") as? Int
            else {
                return false
        }
        let country = mo.valueForKey("country") as? NSManagedObject
        let latitude = mo.valueForKey("latitude") as? Double
        let longitude = mo.valueForKey("longitude") as? Double
        let markedForDeletionDate = mo.valueForKey("markedForDeletionDate") as? NSDate
        let creatorID = mo.valueForKey("creatorID") as? String
        let remoteID = mo.valueForKey("remoteID") as? String

        return self.markedForRemoteDeletion == markedForRemoteDeletion &&
            ((self.country == nil && country == nil) || self.country!.matchesManagedObject(country!)) &&
            self.date == date &&
            self.latitude == latitude &&
            self.longitude == longitude &&
            self.markedForDeletionDate == markedForDeletionDate &&
            self.creatorID == creatorID &&
            self.remoteID == remoteID &&
            self.colors == colors &&
            self.rating == rating
    }
}


private struct CountryV5: TestEntityDataType {
    let entityName = "Country"
    let numberOfMoods: Int
    let numericISO3166Code: Int
    let isoContinent: Int?
    let markedForDeletionDate: NSDate?
    let updatedAt: NSDate
    var moods: [MoodV5] = []

    init(numberOfMoods: Int, numericISO3166Code: Int, isoContinent: Int?, markedForDeletionDate: NSDate?, updatedAt: NSDate) {
        self.numberOfMoods = numberOfMoods
        self.numericISO3166Code = numericISO3166Code
        self.isoContinent = isoContinent
        self.markedForDeletionDate = markedForDeletionDate
        self.updatedAt = updatedAt
    }

    func matchesManagedObject(mo: NSManagedObject) -> Bool {
        guard mo.entity.name == "Country",
            let numberOfMoods = mo.valueForKey("numberOfMoods") as? Int,
            let numericISO3166Code = mo.valueForKey("numericISO3166Code") as? Int,
            let updatedAt = mo.valueForKey("updatedAt") as? NSDate
            else {
                return false
        }
        let isoContinent = mo.valueForKey("isoContinent") as? Int
        let moods = mo.valueForKey("moods") as! Set<NSManagedObject>
        let markedForDeletionDate = mo.valueForKey("markedForDeletionDate") as? NSDate

        return self.numberOfMoods == numberOfMoods &&
            self.numericISO3166Code == numericISO3166Code &&
            self.isoContinent == isoContinent &&
            self.markedForDeletionDate == markedForDeletionDate &&
            self.updatedAt == updatedAt &&
            self.moods.all { m in moods.some { m.matchesManagedObject($0) } }
    }
}


let v5Data: TestVersionData = {
    var country21 = CountryV5(numberOfMoods: 2, numericISO3166Code: 710, isoContinent: 10004, markedForDeletionDate: nil, updatedAt: NSDate(timeIntervalSinceReferenceDate: 464687061.782827))
    var country30 = CountryV5(numberOfMoods: 1, numericISO3166Code: 704, isoContinent: 10005, markedForDeletionDate: nil, updatedAt: NSDate(timeIntervalSinceReferenceDate: 464687061.722586))
    var country31 = CountryV5(numberOfMoods: 1, numericISO3166Code: 231, isoContinent: 10004, markedForDeletionDate: nil, updatedAt: NSDate(timeIntervalSinceReferenceDate: 464687061.668211))

    let mood1 = MoodV5(markedForRemoteDeletion: false, country: country30, date: NSDate(timeIntervalSinceReferenceDate: 464441952.529884), latitude: 13.154376, longitude: 108.193359, markedForDeletionDate: nil, creatorID: "__defaultOwner__", remoteID: "64C6E1D4-7C2E-4F04-B867-1A9E2941F9FF", colors: NSData(base64EncodedString: "a2Va3d/kSEIxJyQLiIeGCwkDOSwLmJmd", options: NSDataBase64DecodingOptions())!, rating: 0)
    let mood2 = MoodV5(markedForRemoteDeletion: false, country: country21, date: NSDate(timeIntervalSinceReferenceDate: 464369360.734390), latitude: -26.000000, longitude: 28.000000, markedForDeletionDate: nil, creatorID: "__defaultOwner__", remoteID: "47300BAD-DE7D-4B54-B94C-04A3EE4CD0C5", colors: NSData(base64EncodedString: "a2Va3d/kSEIxJyQLiIeGCwkDOSwLmJmd", options: NSDataBase64DecodingOptions())!, rating: 0)
    let mood3 = MoodV5(markedForRemoteDeletion: false, country: country31, date: NSDate(timeIntervalSinceReferenceDate: 464442000.641578), latitude: 7.013668, longitude: 41.308594, markedForDeletionDate: nil, creatorID: "__defaultOwner__", remoteID: "83922344-ED0B-4ABE-B8B0-E00F4E7E1D94", colors: NSData(base64EncodedString: "8fP4YVtDZWU3usfgRT8gTE8cTTktfHlf", options: NSDataBase64DecodingOptions())!, rating: 0)
    let mood4 = MoodV5(markedForRemoteDeletion: false, country: country21, date: NSDate(timeIntervalSinceReferenceDate: 464369352.554507), latitude: -26.000000, longitude: 28.000000, markedForDeletionDate: nil, creatorID: "__defaultOwner__", remoteID: "3A9BAEFD-7716-41C0-9FFF-A7C4BCE32679", colors: NSData(base64EncodedString: "XkUa493ZlI1/epW2MSIOFQ8HQSoOTUAs", options: NSDataBase64DecodingOptions())!, rating: 0)

    country21.moods = [mood2, mood4]
    country30.moods = [mood1]
    country31.moods = [mood3]

    return TestVersionData(data: [
        [mood1, mood2, mood3, mood4],
        [country21, country30, country31],
    ])
}()
