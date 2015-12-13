//
//  MoodTableViewCell.swift
//  Moody
//
//  Created by Florian on 07/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import MoodyModel


class MoodTableViewCell: UITableViewCell {
    @IBOutlet weak var moodView: MoodView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var country: UILabel!
}


private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    formatter.doesRelativeDateFormatting = true
    formatter.formattingContext = .Standalone
    return formatter
}()


extension MoodTableViewCell: ConfigurableCell {
    func configureForObject(mood: Mood) {
        moodView.colors = mood.colors
        label.text = sharedDateFormatter.stringFromDate(mood.date)
        country.text = mood.country?.localizedDescription ?? ""
    }
}

