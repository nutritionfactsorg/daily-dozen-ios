//
//  TypesCell.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 10.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class TypesCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var linkButton: UIButton!

    func configure(title: String, useLink: Bool, tag: Int) {
        titleLabel.text = title
        linkButton.isHidden = useLink
        linkButton.tag = tag
    }
}
