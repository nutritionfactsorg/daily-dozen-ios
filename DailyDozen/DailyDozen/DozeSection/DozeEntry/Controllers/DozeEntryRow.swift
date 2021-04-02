//
//  DozeEntryRow.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class DozeEntryRow: UITableViewCell {
    
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
    func configure(itemType: DataCountType, tag: Int, streak: Int = 0) {
        itemHeadingLabel.text = itemType.headingDisplay
        itemStateCollection.tag = tag
        itemInfoButton.tag = tag
        itemCalendarButton.tag = tag
        itemImage.image = UIImage(named: itemType.imageName)
        
        if itemType == .dozeBeverages { // :DEBUG:
            //CGRect(x: <#T##Double#>, y: <#T##Double#>, width: <#T##Double#>, height: <#T##Double#>)
            //CGRect(origin: <#T##CGPoint#>, size: <#T##CGSize#>)
            print(
                """
                :DEBUG: tag=\(tag) imageName='\(itemType.imageName)' heading='\(itemType.headingDisplay)'
                               self.frame=\(self.frame)
                        itemStreakLabel.frame=\(itemStreakLabel.frame)   
                    itemStateCollection.frame=\(itemStateCollection.frame)  
                """)
        }
        
        //itemType.maxServings
        
        if let superview = itemStreakLabel.superview {
            if streak > oneDay { // "1 day" streaks are not shown
                var streakFormat = NSLocalizedString("streakDaysFormat", comment: "streak days format")
                if itemType == .dozeBeverages {
                    // Daily Dozen beverages has 5 checkboxs overlays the streak indicator on small screens.
                    // which requires the `%d days` label to be shortened to just then number.
                    streakFormat = "d%" // no units
                }
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
