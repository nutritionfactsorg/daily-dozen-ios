//
//  DozeEntryTableViewCell.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class DozeEntryTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var itemImage: UIImageView!
    @IBOutlet private weak var streakLabel: UILabel!
    @IBOutlet private weak var itemHeadingLabel: UILabel!
    @IBOutlet weak var stateCollection: UICollectionView!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var calendarButton: UIButton!

    private let oneDay = 1
    private let oneWeek = 7
    private let twoWeeks = 14
    
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

        if let superview = streakLabel.superview {
            if streak > oneDay {
                let streakFormat = NSLocalizedString("streakDaysFormat", comment: "streak days format")
                streakLabel.text = String(format: streakFormat, streak)
                superview.isHidden = false
                
                if streak < oneWeek {
                    superview.backgroundColor = UIColor.streakBronzeColor
                    streakLabel.textColor = UIColor.white
                } else if streak < twoWeeks {
                    superview.backgroundColor = UIColor.streakSilverColor
                    streakLabel.textColor = UIColor.black
                } else {
                    superview.backgroundColor = UIColor.streakGoldColor
                    streakLabel.textColor = UIColor.black
                }
                
            } else {
                superview.isHidden = true
            }
        }
    }
}
