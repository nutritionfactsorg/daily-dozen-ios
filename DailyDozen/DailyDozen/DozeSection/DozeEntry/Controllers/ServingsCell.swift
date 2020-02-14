//
//  ServingsCell.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class ServingsCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var itemImage: UIImageView!
    @IBOutlet private weak var streakLabel: UILabel!
    @IBOutlet private weak var itemHeadingLabel: UILabel!
    @IBOutlet weak var stateCollection: UICollectionView!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var calendarButton: UIButton!

    // MARK: - Methods
    /// Sets the servings cell with the current heading, image name and row index tag.
    ///
    /// - Parameter heading: The current heading.
    /// - Parameter tag: The current row index tag.
    /// - Parameter imageName: The image filename tag.
    func configure(heading: String, tag: Int, imageName: String, streak: Int = 0) {
        itemHeadingLabel.text = heading
        stateCollection.tag = tag
        infoButton.tag = tag
        calendarButton.tag = tag
        itemImage.image = UIImage(named: imageName)

        if streak > 1 {
            streakLabel.text = "\(streak) days" // :NYI:ToBeLocalized:
            streakLabel.superview?.isHidden = false
        } else {
            streakLabel.superview?.isHidden = true
        }
    }
}
