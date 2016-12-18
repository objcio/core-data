//
//  V6.swift
//  Migrations
//
//  Created by Florian on 03/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import UIKit
@testable import Migrations


private struct MoodV6: TestEntityData {
    let entityName = "Mood"
    let markedForRemoteDeletion: Bool
    let country: CountryV6?
    let date: Date
    let latitude: Double?
    let longitude: Double?
    let markedForDeletionDate: Date?
    let creatorID: String?
    let remoteID: String?
    let colors: [UIColor]
    let rating: Int

    init(markedForRemoteDeletion: Bool, country: CountryV6?, date: Date, latitude: Double, longitude: Double, markedForDeletionDate: Date?, creatorID: String?, remoteID: String?, colors: Data, rating: Int) {
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

    func matches(_ object: NSManagedObject) -> Bool {
        guard object.entity.name == "Mood",
            let markedForRemoteDeletion = object.value(forKey: "markedForRemoteDeletion") as? Bool,
            let date = object.value(forKey: "date") as? Date,
            let colors = object.value(forKey: "colors") as? [UIColor],
            let rating = object.value(forKey: "rating") as? Int
            else {
                return false
        }
        let country = object.value(forKey: "country") as? NSManagedObject
        let latitude = object.value(forKey: "latitude") as? Double
        let longitude = object.value(forKey: "longitude") as? Double
        let markedForDeletionDate = object.value(forKey: "markedForDeletionDate") as? Date
        let creatorID = object.value(forKey: "creatorID") as? String
        let remoteID = object.value(forKey: "remoteID") as? String

        return self.markedForRemoteDeletion == markedForRemoteDeletion &&
            ((self.country == nil && country == nil) || self.country!.matches(country!)) &&
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


private struct CountryV6: TestEntityData {
    let entityName = "Country"
    let numberOfMoods: Int
    let numericISO3166Code: Int
    let markedForDeletionDate: Date?
    let updatedAt: Date
    var moods: [MoodV6] = []
    let continent: ContinentV6?

    init(numberOfMoods: Int, numericISO3166Code: Int, continent: ContinentV6?, markedForDeletionDate: Date?, updatedAt: Date) {
        self.numberOfMoods = numberOfMoods
        self.numericISO3166Code = numericISO3166Code
        self.continent = continent
        self.markedForDeletionDate = markedForDeletionDate
        self.updatedAt = updatedAt
    }

    func matches(_ object: NSManagedObject) -> Bool {
        guard object.entity.name == "Country",
            let numberOfMoods = object.value(forKey: "numberOfMoods") as? Int,
            let numericISO3166Code = object.value(forKey: "numericISO3166Code") as? Int,
            let updatedAt = object.value(forKey: "updatedAt") as? Date
            else {
                return false
        }
        let continent = object.value(forKey: "continent") as? NSManagedObject
        let moods = object.value(forKey: "moods") as! Set<NSManagedObject>
        let markedForDeletionDate = object.value(forKey: "markedForDeletionDate") as? Date

        return self.numberOfMoods == numberOfMoods &&
            self.numericISO3166Code == numericISO3166Code &&
            ((self.continent == nil && continent == nil) || self.continent!.matches(continent!)) &&
            self.markedForDeletionDate == markedForDeletionDate &&
            self.updatedAt == updatedAt &&
            self.moods.all { m in moods.some { m.matches($0) } }
    }
}


private struct ContinentV6: TestEntityData {
    let entityName = "Continent"
    let numericISO3166Code: Int
    var countries: [CountryV6] = []

    init(numericISO3166Code: Int) {
        self.numericISO3166Code = numericISO3166Code
    }

    func matches(_ object: NSManagedObject) -> Bool {
        guard object.entity.name == "Continent",
            let numericISO3166Code = object.value(forKey: "numericISO3166Code") as? Int
        else {
            return false
        }
        let countries = object.value(forKey: "countries") as! Set<NSManagedObject>

        return self.numericISO3166Code == numericISO3166Code &&
            self.countries.all { c in countries.some { c.matches($0) } }
    }
}


let v6Data: TestVersionData = {
    let continent1 = ContinentV6(numericISO3166Code: 10004)
    let continent2 = ContinentV6(numericISO3166Code: 10005)

    var country21 = CountryV6(numberOfMoods: 2, numericISO3166Code: 710, continent: continent1, markedForDeletionDate: nil, updatedAt: Date(timeIntervalSinceReferenceDate: 464687061.782827))
    var country30 = CountryV6(numberOfMoods: 1, numericISO3166Code: 704, continent: continent2, markedForDeletionDate: nil, updatedAt: Date(timeIntervalSinceReferenceDate: 464687061.722586))
    var country31 = CountryV6(numberOfMoods: 1, numericISO3166Code: 231, continent: continent1, markedForDeletionDate: nil, updatedAt: Date(timeIntervalSinceReferenceDate: 464687061.668211))

    let mood1 = MoodV6(markedForRemoteDeletion: false, country: country30, date: Date(timeIntervalSinceReferenceDate: 464441952.529884), latitude: 13.154376, longitude: 108.193359, markedForDeletionDate: nil, creatorID: "__defaultOwner__", remoteID: "64C6E1D4-7C2E-4F04-B867-1A9E2941F9FF", colors: Data(base64Encoded: "a2Va3d/kSEIxJyQLiIeGCwkDOSwLmJmd", options: NSData.Base64DecodingOptions())!, rating: 0)
    let mood2 = MoodV6(markedForRemoteDeletion: false, country: country21, date: Date(timeIntervalSinceReferenceDate: 464369360.734390), latitude: -26.000000, longitude: 28.000000, markedForDeletionDate: nil, creatorID: "__defaultOwner__", remoteID: "47300BAD-DE7D-4B54-B94C-04A3EE4CD0C5", colors: Data(base64Encoded: "a2Va3d/kSEIxJyQLiIeGCwkDOSwLmJmd", options: NSData.Base64DecodingOptions())!, rating: 0)
    let mood3 = MoodV6(markedForRemoteDeletion: false, country: country31, date: Date(timeIntervalSinceReferenceDate: 464442000.641578), latitude: 7.013668, longitude: 41.308594, markedForDeletionDate: nil, creatorID: "__defaultOwner__", remoteID: "83922344-ED0B-4ABE-B8B0-E00F4E7E1D94", colors: Data(base64Encoded: "8fP4YVtDZWU3usfgRT8gTE8cTTktfHlf", options: NSData.Base64DecodingOptions())!, rating: 0)
    let mood4 = MoodV6(markedForRemoteDeletion: false, country: country21, date: Date(timeIntervalSinceReferenceDate: 464369352.554507), latitude: -26.000000, longitude: 28.000000, markedForDeletionDate: nil, creatorID: "__defaultOwner__", remoteID: "3A9BAEFD-7716-41C0-9FFF-A7C4BCE32679", colors: Data(base64Encoded: "XkUa493ZlI1/epW2MSIOFQ8HQSoOTUAs", options: NSData.Base64DecodingOptions())!, rating: 0)

    country21.moods = [mood2, mood4]
    country30.moods = [mood1]
    country31.moods = [mood3]

    return TestVersionData(data: [
        [mood1, mood2, mood3, mood4],
        [country21, country30, country31],
        [continent1, continent2],
    ])
}()

