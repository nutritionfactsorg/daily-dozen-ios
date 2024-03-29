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
    var itemDataCountType: DataCountType!

    private let oneDay = 1
    private let oneWeek = 7
    private let twoWeeks = 14
    
    // MARK: - Methods
    
    /// Sets the servings cell with the current heading, image name and row index tag.
    ///
    /// - Parameter heading: The current heading.
    /// - Parameter tag: The current row index tag.
    /// - Parameter imageName: The image filename tag.
    func configure(itemType: DataCountType, tag: Int, streak: Int = 0) {
        itemHeadingLabel.text = itemType.headingDisplay
        itemStateCollection.tag = tag
        itemInfoButton.tag = tag
        itemCalendarButton.tag = tag
        itemImage.image = UIImage(named: itemType.imageName)
        itemDataCountType = itemType
        self.accessibilityIdentifier = itemType.typeKey.appending("_access")

        if let superview = itemStreakLabel.superview {
            if streak > oneDay {
                let streakFormat = NSLocalizedString("streakDaysFormat", comment: "streak days format")
                itemStreakLabel.text = String(format: streakFormat, streak)
                superview.isHidden = false
                
                if streak < oneWeek {
                    superview.backgroundColor = ColorManager.style.streakBronze
                    itemStreakLabel.textColor = UIColor.white
                } else if streak < twoWeeks {
                    superview.backgroundColor = ColorManager.style.streakSilver
                    itemStreakLabel.textColor = UIColor.black
                } else {
                    superview.backgroundColor = ColorManager.style.streakGold
                    itemStreakLabel.textColor = UIColor.black
                }
                
            } else {
                superview.isHidden = true
            }
        }
    }
}
