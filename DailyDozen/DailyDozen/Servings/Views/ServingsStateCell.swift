//
//  ServingsStateCell.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 25.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class ServingsStateCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet private weak var checkbox: UIButtonCheckbox!
    
    // MARK: - Methods
    
    /// Sets the checkbox with the current state.  Toggle border color.
    ///
    /// - Parameter state: The current state.
    func configure(with state: Bool) {
        checkbox.isSelected = state
        // Border color must match image background in UIButtonCheckbox setCheckboxImage()
        // UIColor.greenColor        "ic_checkmark_white_green"
        // UIColor.redCheckmarkColor "ic_checkmark_white_red"
        checkbox.layer.borderColor = state ? UIColor.greenColor.cgColor : UIColor.grayLightColor.cgColor
    }
}
