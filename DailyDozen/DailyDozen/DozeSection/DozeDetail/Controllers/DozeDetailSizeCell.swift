//
//  DozeDetailSizeCell.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import UIKit

class DozeDetailSizeCell: UITableViewCell {

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
