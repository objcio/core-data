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
import CoreDataHelpers


public final class Mood: ManagedObject {

    @NSManaged public private(set) var date: NSDate
    @NSManaged public private(set) var colors: [UIColor]
    public var location: CLLocation? {
        guard let lat = latitude, lon = longitude else { return nil }
        return CLLocation(latitude: lat.doubleValue, longitude: lon.doubleValue)
    }

    @NSManaged public var creatorID: String?
    @NSManaged public var remoteIdentifier: RemoteRecordID?

    @NSManaged public private(set) var country___: Country
    @NSManaged public private(set) var country: Country?


    public override func awakeFromInsert() {
        super.awakeFromInsert()
        primitiveDate = NSDate()
    }

    public static func insertIntoContext(moc: NSManagedObjectContext, image: UIImage) -> Mood {
        let mood: Mood = moc.insertObject()
        mood.colors = image.moodColors
        mood.date = NSDate()
        return mood
    }


    public static func insertIntoContext(moc: NSManagedObjectContext, image: UIImage, location: CLLocation?, placemark: CLPlacemark?) -> Mood {
        let iso3166 = ISO3166.Country.fromISO3166(placemark?.ISOcountryCode ?? "")
        return insertIntoContext(moc, colors: image.moodColors, location: location, isoCountry: iso3166)
    }

    public static func insertIntoContext(moc: NSManagedObjectContext, colors: [UIColor], location: CLLocation?, isoCountry: ISO3166.Country, remoteIdentifier: RemoteRecordID? = nil, date: NSDate? = nil, creatorID: String? = nil) -> Mood {
        let mood: Mood = moc.insertObject()
        mood.colors = colors
        if let coord = location?.coordinate {
            mood.latitude = coord.latitude
            mood.longitude = coord.longitude
        }
        mood.country = Country.findOrCreateCountry(isoCountry, inContext: moc)
        mood.remoteIdentifier = remoteIdentifier
        if let d = date {
            mood.date = d
        }
        mood.creatorID = creatorID
        return mood
    }

    public override func willSave() {
        super.willSave()
        if changedForDelayedDeletion || changedForRemoteDeletion {
            removeFromCountry()
        }
    }


    // MARK: Private

    @NSManaged private var primitiveDate: NSDate
    @NSManaged private var latitude: NSNumber?
    @NSManaged private var longitude: NSNumber?


    private func removeFromCountry() {
        guard country != nil else { return }
        country = nil
    }

}


extension Mood: KeyCodable {
    public enum Keys: String {
        case Colors = "colors"
    }
}


extension Mood: ManagedObjectType {

    public static var entityName: String {
        return "Mood"
    }

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "date", ascending: false)]
    }

    public static var defaultPredicate: NSPredicate {
        return notMarkedForDeletionPredicate
    }

}


extension Mood: DelayedDeletable {
    @NSManaged public var markedForDeletionDate: NSDate?
}


extension Mood: RemoteDeletable {
    @NSManaged public var markedForRemoteDeletion: Bool
}


private let MaxColors = 8

extension UIImage {
    private var moodColors: [UIColor] {
        var colors: [UIColor] = []
        for c in dominantColors(.Moody) where colors.count < MaxColors {
            colors.append(c)
        }
        return colors
    }
}

extension NSData {
    public var moodColors: [UIColor]? {
        guard length > 0 && length % 3 == 0 else { return nil }
        var rgbValues = Array(count: length, repeatedValue: UInt8())
        rgbValues.withUnsafeMutableBufferPointer { buffer -> () in
            let voidPointer = UnsafeMutablePointer<Void>(buffer.baseAddress)
            memcpy(voidPointer, bytes, length)
        }
        let rgbSlices = rgbValues.slices(3)
        return rgbSlices.map { slice in
            guard let color = UIColor(rawData: slice) else { fatalError("cannot fail since we know tuple is of length 3") }
            return color
        }
    }
}


extension SequenceType where Generator.Element == UIColor {
    public var moodData: NSData {
        let rgbValues = flatMap { $0.rgb }
        return rgbValues.withUnsafeBufferPointer {
            return NSData(bytes: $0.baseAddress, length: $0.count)
        }
    }
}


private var registrationToken: dispatch_once_t = 0
private let ColorsTransformerName = "ColorsTransformer"

extension Mood {
    static func registerValueTransformers() {
        dispatch_once(&registrationToken) {
            ValueTransformer.registerTransformerWithName(ColorsTransformerName, transform: { colors in
                guard let colors = colors as? [UIColor] else { return nil }
                return colors.moodData
            }, reverseTransform: { (data: NSData?) -> NSArray? in
                return data?.moodColors
            })
        }
    }
}


extension UIColor {

    private var rgb: [UInt8] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return [UInt8(red * 255), UInt8(green * 255), UInt8(blue * 255)]
    }

    private convenience init?(rawData: [UInt8]) {
        if rawData.count != 3 { return nil }
        let red = CGFloat(rawData[0]) / 255
        let green = CGFloat(rawData[1]) / 255
        let blue = CGFloat(rawData[2]) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

}

