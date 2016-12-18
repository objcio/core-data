//
//  MoodCollectionViewCell.swift
//  Moody
//
//  Created by Florian on 27/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit
import MoodyModel


class MoodCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var moodView: MoodView!
}


extension MoodCollectionViewCell {
    func configure(for mood: Mood) {
        moodView.colors = mood.colors
    }
}


