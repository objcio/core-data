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


public class Mood: NSManagedObject {

    @NSManaged public fileprivate(set) var date: Date
    @NSManaged public fileprivate(set) var colors: [UIColor]
    public var location: CLLocation? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocation(latitude: lat.doubleValue, longitude: lon.doubleValue)
    }

    @NSManaged public var creatorID: String?
    @NSManaged public var remoteIdentifier: RemoteRecordID?

    @NSManaged public fileprivate(set) var country___: Country
    @NSManaged public fileprivate(set) var country: Country?


    public override func awakeFromInsert() {
        super.awakeFromInsert()
        primitiveDate = Date()
    }

    public static func insert(into moc: NSManagedObjectContext, image: UIImage) -> Mood {
        let mood: Mood = moc.insertObject()
        mood.colors = image.moodColors
        mood.date = Date()
        return mood
    }


    public static func insert(into moc: NSManagedObjectContext, image: UIImage, location: CLLocation?, placemark: CLPlacemark?) -> Mood {
        let iso3166 = ISO3166.Country.fromISO3166(placemark?.isoCountryCode ?? "")
        return insert(into: moc, colors: image.moodColors, location: location, isoCountry: iso3166)
    }

    public static func insert(into moc: NSManagedObjectContext, colors: [UIColor], location: CLLocation?, isoCountry: ISO3166.Country, remoteIdentifier: RemoteRecordID? = nil, date: Date? = nil, creatorID: String? = nil) -> Mood {
        let mood: Mood = moc.insertObject()
        mood.colors = colors
        if let coord = location?.coordinate {
            mood.latitude = NSNumber(value: coord.latitude)
            mood.longitude = NSNumber(value: coord.longitude)
        }
        mood.country = Country.findOrCreate(for: isoCountry, in: moc)
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

    @NSManaged fileprivate var primitiveDate: Date
    @NSManaged fileprivate var latitude: NSNumber?
    @NSManaged fileprivate var longitude: NSNumber?


    fileprivate func removeFromCountry() {
        guard country != nil else { return }
        country = nil
    }

}


extension Mood: Managed {

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(date), ascending: false)]
    }

    public static var defaultPredicate: NSPredicate {
        return notMarkedForDeletionPredicate
    }

}


extension Mood: DelayedDeletable {
    @NSManaged public var markedForDeletionDate: Date?
}


extension Mood: RemoteDeletable {
    @NSManaged public var markedForRemoteDeletion: Bool
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

extension Data {
    public var moodColors: [UIColor]? {
        guard count > 0 && count % 3 == 0 else { return nil }
        var rgbValues = Array(repeating: UInt8(), count: count)
        rgbValues.withUnsafeMutableBufferPointer { buffer in
            let voidPointer = UnsafeMutableRawPointer(buffer.baseAddress)
            let _ = withUnsafeBytes { bytes in
                memcpy(voidPointer, bytes, count)
            }
        }
        let rgbSlices = rgbValues.sliced(size: 3)
        return rgbSlices.map { slice in
            guard let color = UIColor(rawData: slice) else { fatalError("cannot fail since we know tuple is of length 3") }
            return color
        }
    }
}


extension Sequence where Iterator.Element == UIColor {
    public var moodData: Data {
        let rgbValues = flatMap { $0.rgb }
        return rgbValues.withUnsafeBufferPointer {
            return Data(bytes: UnsafePointer<UInt8>($0.baseAddress!),
                count: $0.count)
        }
    }
}


private let ColorsTransformerName = "ColorsTransformer"

extension Mood {
    static func registerValueTransformers() {
        _ = self.__registerOnce
    }
    fileprivate static let __registerOnce: () = {
        ClosureValueTransformer.registerTransformer(withName: ColorsTransformerName, transform: { (colors: NSArray?) -> NSData? in
                guard let colors = colors as? [UIColor] else { return nil }
                return colors.moodData as NSData
            }, reverseTransform: { (data: NSData?) -> NSArray? in
                return data
                    .flatMap { ($0 as Data).moodColors }
                    .map { $0 as NSArray }
        })
    }()
}


extension UIColor {

    fileprivate var rgb: [UInt8] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return [UInt8(red * 255), UInt8(green * 255), UInt8(blue * 255)]
    }

    fileprivate convenience init?(rawData: [UInt8]) {
        if rawData.count != 3 { return nil }
        let red = CGFloat(rawData[0]) / 255
        let green = CGFloat(rawData[1]) / 255
        let blue = CGFloat(rawData[2]) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

}


