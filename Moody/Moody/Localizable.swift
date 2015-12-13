//
//  Localizable.swift
//  Moody
//
//  Created by Daniel Eggert on 08/09/2015.
//  Copyright © 2015 objc.io. All rights reserved.
//

import Foundation

enum LocalizedText: String {
    case CameraView_tapToCapture = "CameraView.tapToCapture"
    case CameraView_needAccess = "CameraView.needAccess"

    case Mood_dateComponentFormat = "Mood.dateComponentFormat"

    case MoodPresentation_list = "MoodPresentation.list"
    case MoodPresentation_grid = "MoodPresentation.grid"

    case MoodSource_all = "MoodSource.all"
    case MoodSource_your = "MoodSource.your"
    case MoodSource_all_detail = "MoodSource.all.detail"
    case MoodSource_you_detail = "MoodSource.you.detail"

    case Regions_title = "Regions.title"
    case Regions_numberOfMoods = "Regions.numberOfMoods"
    case Regions_numberOfMoodsInCountries = "Regions.numberOfMoodsInCountries"
}

func localized(key: LocalizedText) -> String {
    return NSLocalizedString(key.rawValue, tableName: nil, bundle: NSBundle.mainBundle(), value: key.rawValue, comment: "")
}


func localized(key: LocalizedText, args: [CVarArgType]) -> String {
    let format = localized(key)
    return withVaList(args) { arguments -> String in
        return NSString(format: format, locale: NSLocale.currentLocale(), arguments: arguments) as String
    }
}
