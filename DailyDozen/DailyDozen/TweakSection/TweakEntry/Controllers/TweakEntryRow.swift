//
//  TweakEntryRow.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

class TweakEntryRow: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet private weak var itemImage: UIImageView!
    @IBOutlet private weak var itemStreakLabel: UILabel!
    @IBOutlet private weak var itemHeadingLabel: UILabel!
    @IBOutlet weak var itemStateCollection: UICollectionView!
    @IBOutlet private weak var itemInfoButton: UIButton!
    @IBOutlet private weak var itemCalendarButton: UIButton!

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
        itemStateCollection.tag = tag
        itemInfoButton.tag = tag
        itemCalendarButton.tag = tag
        itemImage.image = UIImage(named: imageName)

        if let superview = itemStreakLabel.superview {
            if streak > oneDay {
                let streakFormat = NSLocalizedString("streakDaysFormat", comment: "streak days format")
                itemStreakLabel.text = String(format: streakFormat, streak)
                superview.isHidden = false
                
                if streak < oneWeek {
                    superview.backgroundColor = UIColor.streakBronzeColor
                    itemStreakLabel.textColor = UIColor.white
                } else if streak < twoWeeks {
                    superview.backgroundColor = UIColor.streakSilverColor
                    itemStreakLabel.textColor = UIColor.black
                } else {
                    superview.backgroundColor = UIColor.streakGoldColor
                    itemStreakLabel.textColor = UIColor.black
                }
                
            } else {
                superview.isHidden = true
            }
        }
    }
}
