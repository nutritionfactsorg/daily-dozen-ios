//
//  TweakEntryStateCell.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

class TweakEntryStateCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet private weak var checkbox: UIButtonCheckbox!
    
    // MARK: - Methods
    
    /// Sets the checkbox with the current state.  Toggle border color.
    ///
    /// - Parameter state: The current state.
    func configure(with state: Bool) {
        checkbox.isSelected = state
        // Border color must match image background in UIButtonCheckbox setCheckboxImage()
        // See "ic_checkmark_fill"
        checkbox.layer.borderColor = state ? UIColor.greenColor.cgColor : UIColor.grayLightColor.cgColor
    }
}
