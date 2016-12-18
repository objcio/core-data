//
//  RegionTableViewCell.swift
//  Moody
//
//  Created by Florian on 27/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit
import MoodyModel

class RegionTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
}


extension RegionTableViewCell {
    func configure(for object: DisplayableRegion) {
        titleLabel.text = object.localizedDescription
        detailLabel.text = object.localizedDetailDescription
    }
}

