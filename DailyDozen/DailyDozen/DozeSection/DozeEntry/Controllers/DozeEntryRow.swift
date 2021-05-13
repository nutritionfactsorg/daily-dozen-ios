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
    @IBOutlet weak var itemStatesWidth: NSLayoutConstraint!  // :TBD: adjust as needed
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
        
        if let superview = itemStreakLabel.superview {
            if streak > oneDay { // "1 day" streaks are not shown
                var streakFormat = NSLocalizedString("streakDaysFormat", comment: "streak days format")
                // self.frame.width values:
                // 320 - iPhone 5S, SE (1st), iPod (7th) 
                // 375 - iPhone 8, SE (2nd), 12 mini
                // 428 - iPhone 12 Pro Max
                if itemType == .dozeBeverages && self.frame.width < 374.0 {
                    // Daily Dozen beverages has 5 checkboxs overlays the streak indicator on small screens.
                    // which requires the `%d days` label to be shortened to just then number.
                    streakFormat = "%d" // no units
                    if streak > 999 {
                        streakFormat = "🏆" // trophy prize    
                    }
                    
                    // Note: adjust contraint instead, if needed.
                    //var f = itemStateCollection.frame
                    //f.size.width = 33.0 // 165.0 / 5.0 = 33
                    //itemStateCollection.frame = f

                }
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
        
        //if itemType == .dozeBeverages || itemType == .dozeWholeGrains { // :DEBUG:
            //CGRect(x, y, width, height) or CGRect(origin, size)
            //print("tag=\(tag) \(itemType.imageName) width=\(self.frame.width)")
            //print(
            //    """
            //    :DEBUG: tag=\(tag) imageName='\(itemType.imageName)' heading='\(itemType.headingDisplay)'
            //               DozeEntryRow.frame=\(self.frame)
            //            itemStreakLabel.frame=\(itemStreakLabel.frame)   
            //        itemStateCollection.frame=\(itemStateCollection.frame)  
            //    """)
        //}

    }
    
}
