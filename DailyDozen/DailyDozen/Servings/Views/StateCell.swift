//
//  DoseCell.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 25.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import UICheckbox_Swift

class StateCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var checkbox: UICheckbox!

    // MARK: - Methods
    /// Sets the checkbox with the current state.
    ///
    /// - Parameter state: The current state.
    func configure(with state: Bool) {
        checkbox.isSelected = state
    }
}
