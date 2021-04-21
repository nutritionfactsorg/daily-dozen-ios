//
//  TweakDetailDescriptionCell.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import UIKit

class TweakDetailDescriptionCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var linkButton: UIButton!

    // MARK: - Methods
    /// Sets the cell data.
    ///
    /// - Parameters:
    ///   - title: The title text.
    ///   - useLink: The new state for the link button.
    ///   - tag: The button tag.
    func configure(title: String, useLink: Bool, tag: Int) {
        titleLabel.text = title
        linkButton.isHidden = useLink
        linkButton.tag = tag
    }

    // Use: 21 Tweaks
    func configure(title: String) {
        titleLabel.text = title
    }

}
