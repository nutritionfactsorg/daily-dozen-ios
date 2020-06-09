//
//  TweakDetailActivityCell.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class TweakDetailActivityCell: UITableViewCell {

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
