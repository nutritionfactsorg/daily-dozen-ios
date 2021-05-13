//
//  DozeItemStateCheckbox.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class DozeItemStateCheckbox: UICollectionViewCell {
    
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
        checkbox.layer.borderColor = state ? ColorManager.style.checkboxBorderChecked.cgColor : ColorManager.style.checkboxBorderUnchecked.cgColor
    }
}

// MARK: - States UICollectionViewDelegate

/// `UICollectionViewDelegate` is an extension in `DozeEntryViewController`
/// 
/// Provides `collectionView(collectionView: UICollectionView, didSelectItemAt: IndexPath)`
/// 
/// - toggles checkmark states
/// - updates Realm database
/// - updates streaks
