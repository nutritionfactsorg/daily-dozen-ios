//
//  SizesCell.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 10.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class SizesCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - Methods.
    /// Sets the new title text.
    ///
    /// - Parameter title: The new title text.
    func configure(title: String) {
        titleLabel.text = title
    }
}
