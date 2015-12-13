//
//  V3.swift
//  Migrations
//
//  Created by Florian on 03/10/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData
import UIKit
@testable import Migrations


private struct MoodV3: TestEntityDataType {
    let entityName = "Mood"
    let markedForRemoteDeletion: Bool
    let country: CountryV3?
    let continent: ContinentV3?
    let date: NSDate
    let latitude: Double?
    let longitude: Double?
    let markedForDeletionDate: NSDate?
    let creatorID: String?
    let remoteID: String?
    let colors: [UIColor]
    let rating: Int

    init(markedForRemoteDeletion: Bool, country: CountryV3?, continent: ContinentV3?, date: NSDate, latitude: Double, longitude: Double, markedForDeletionDate: NSDate?, creatorID: String?, remoteID: String?, colors: NSData, rating: Int) {
        self.markedForRemoteDeletion = markedForRemoteDeletion
        self.country = country
        self.continent = continent
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
        let continent = mo.valueForKey("continent") as? NSManagedObject
        let latitude = mo.valueForKey("latitude") as? Double
        let longitude = mo.valueForKey("longitude") as? Double
        let markedForDeletionDate = mo.valueForKey("markedForDeletionDate") as? NSDate
        let creatorID = mo.valueForKey("creatorID") as? String
        let remoteID = mo.valueForKey("remoteID") as? String

        return self.markedForRemoteDeletion == markedForRemoteDeletion &&
            ((self.country == nil && country == nil) || self.country!.matchesManagedObject(country!)) &&
            ((self.continent == nil && continent == nil) || self.continent!.matchesManagedObject(continent!)) &&
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


private struct CountryV3: TestEntityDataType {
    let entityName = "Country"
    let numberOfMoods: Int
    let numericISO3166Code: Int
    let continent: ContinentV3?
    let markedForDeletionDate: NSDate?
    let updatedAt: NSDate
    var moods: [MoodV3] = []

    init(numberOfMoods: Int, numericISO3166Code: Int, continent: ContinentV3?, markedForDeletionDate: NSDate?, updatedAt: NSDate) {
        self.numberOfMoods = numberOfMoods
        self.numericISO3166Code = numericISO3166Code
        self.continent = continent
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
        let continent = mo.valueForKey("continent") as? NSManagedObject
        let moods = mo.valueForKey("moods") as! Set<NSManagedObject>
        let markedForDeletionDate = mo.valueForKey("markedForDeletionDate") as? NSDate

        return self.numberOfMoods == numberOfMoods &&
            self.numericISO3166Code == numericISO3166Code &&
            ((self.continent == nil && continent == nil) || self.continent!.matchesManagedObject(continent!)) &&
            self.markedForDeletionDate == markedForDeletionDate &&
            self.updatedAt == updatedAt &&
            self.moods.all { m in moods.some { m.matchesManagedObject($0) } }
    }
}


private struct ContinentV3: TestEntityDataType {
    let entityName = "Continent"
    let numberOfMoods: Int
    let numberOfCountries: Int
    let numericISO3166Code: Int
    let markedForDeletionDate: NSDate?
    let updatedAt: NSDate
    var countries: [CountryV3] = []
    var moods: [MoodV3] = []

    init(numberOfMoods: Int, numberOfCountries: Int, numericISO3166Code: Int, markedForDeletionDate: NSDate?, updatedAt: NSDate) {
        self.numberOfMoods = numberOfMoods
        self.numberOfCountries = numberOfCountries
        self.numericISO3166Code = numericISO3166Code
        self.markedForDeletionDate = markedForDeletionDate
        self.updatedAt = updatedAt
    }

    func matchesManagedObject(mo: NSManagedObject) -> Bool {
        guard mo.entity.name == "Continent",
            let numberOfMoods = mo.valueForKey("numberOfMoods") as? Int,
            let numberOfCountries = mo.valueForKey("numberOfCountries") as? Int,
            let numericISO3166Code = mo.valueForKey("numericISO3166Code") as? Int,
            let updatedAt = mo.valueForKey("updatedAt") as? NSDate
            else {
                return false
        }
        let markedForDeletionDate = mo.valueForKey("markedForDeletionDate") as? NSDate
        let countries = mo.valueForKey("countries") as! Set<NSManagedObject>
        let moods = mo.valueForKey("moods") as! Set<NSManagedObject>

        return self.numberOfMoods == numberOfMoods &&
            self.numberOfCountries == numberOfCountries &&
            self.numericISO3166Code == numericISO3166Code &&
            self.markedForDeletionDate == markedForDeletionDate &&
            self.updatedAt == updatedAt &&
            self.countries.all { c in countries.some { c.matchesManagedObject($0) } } &&
            self.moods.all { m in moods.some { m.matchesManagedObject($0) } }
    }
}


let v3Data: TestVersionData = {
    var continent1 = ContinentV3(numberOfMoods: 8, numberOfCountries: 6, numericISO3166Code: 10005, markedForDeletionDate: nil, updatedAt: NSDate(timeIntervalSinceReferenceDate: 465131737.392830))
    var continent2 = ContinentV3(numberOfMoods: 8, numberOfCountries: 4, numericISO3166Code: 10004, markedForDeletionDate: nil, updatedAt: NSDate(timeIntervalSinceReferenceDate: 464687061.663903))

    var country21 = CountryV3(numberOfMoods: 2, numericISO3166Code: 710, continent: continent2, markedForDeletionDate: nil, updatedAt: NSDate(timeIntervalSinceReferenceDate: 464687061.782827))
    var country30 = CountryV3(numberOfMoods: 1, numericISO3166Code: 704, continent: continent1, markedForDeletionDate: nil, updatedAt: NSDate(timeIntervalSinceReferenceDate: 464687061.722586))
    var country31 = CountryV3(numberOfMoods: 1, numericISO3166Code: 231, continent: continent2, markedForDeletionDate: nil, updatedAt: NSDate(timeIntervalSinceReferenceDate: 464687061.668211))

    let mood1 = MoodV3(markedForRemoteDeletion: false, country: country30, continent: continent1, date: NSDate(timeIntervalSinceReferenceDate: 464441952.529884), latitude: 13.154376, longitude: 108.193359, markedForDeletionDate: nil, creatorID: "__defaultOwner__", remoteID: "64C6E1D4-7C2E-4F04-B867-1A9E2941F9FF", colors: NSData(base64EncodedString: "a2Va3d/kSEIxJyQLiIeGCwkDOSwLmJmd", options: NSDataBase64DecodingOptions())!, rating: 0)
    let mood2 = MoodV3(markedForRemoteDeletion: false, country: country21, continent: continent2, date: NSDate(timeIntervalSinceReferenceDate: 464369360.734390), latitude: -26.000000, longitude: 28.000000, markedForDeletionDate: nil, creatorID: "__defaultOwner__", remoteID: "47300BAD-DE7D-4B54-B94C-04A3EE4CD0C5", colors: NSData(base64EncodedString: "a2Va3d/kSEIxJyQLiIeGCwkDOSwLmJmd", options: NSDataBase64DecodingOptions())!, rating: 0)
    let mood3 = MoodV3(markedForRemoteDeletion: false, country: country31, continent: continent2, date: NSDate(timeIntervalSinceReferenceDate: 464442000.641578), latitude: 7.013668, longitude: 41.308594, markedForDeletionDate: nil, creatorID: "__defaultOwner__", remoteID: "83922344-ED0B-4ABE-B8B0-E00F4E7E1D94", colors: NSData(base64EncodedString: "8fP4YVtDZWU3usfgRT8gTE8cTTktfHlf", options: NSDataBase64DecodingOptions())!, rating: 0)
    let mood4 = MoodV3(markedForRemoteDeletion: false, country: country21, continent: continent2, date: NSDate(timeIntervalSinceReferenceDate: 464369352.554507), latitude: -26.000000, longitude: 28.000000, markedForDeletionDate: nil, creatorID: "__defaultOwner__", remoteID: "3A9BAEFD-7716-41C0-9FFF-A7C4BCE32679", colors: NSData(base64EncodedString: "XkUa493ZlI1/epW2MSIOFQ8HQSoOTUAs", options: NSDataBase64DecodingOptions())!, rating: 0)

    continent1.countries = [country30]
    continent1.moods = [mood1]
    continent2.countries = [country21, country31]
    continent2.moods = [mood2, mood3, mood4]

    country21.moods = [mood2, mood4]
    country30.moods = [mood1]
    country31.moods = [mood3]

    return TestVersionData(data: [
        [mood1, mood2, mood3, mood4],
        [country21, country30, country31],
        [continent1, continent2],
    ])
}()
