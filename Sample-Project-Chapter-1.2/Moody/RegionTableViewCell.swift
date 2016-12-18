//
//  RegionTableViewCell.swift
//  Moody
//
//  Created by Florian on 27/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit

class RegionTableViewCell: UITableViewCell {}

extension RegionTableViewCell {
    func configure(for object: LocalizedStringConvertible) {
        textLabel?.text = object.localizedDescription
    }
}

