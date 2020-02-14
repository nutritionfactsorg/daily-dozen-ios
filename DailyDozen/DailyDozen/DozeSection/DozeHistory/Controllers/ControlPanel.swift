//
//  ControlPanel.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 07.12.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class ControlPanel: UIStackView {

    // MARK: - Outlets
    @IBOutlet private weak var toFirstButton: RoundedButton!
    @IBOutlet private weak var toPreviousButton: RoundedButton!
    @IBOutlet private weak var toNextButton: RoundedButton!
    @IBOutlet private weak var toLastButton: RoundedButton!

    @IBOutlet private weak var monthLabel: UILabel! {
        didSet {
            monthLabel.isHidden = monthLabel.text == nil
        }
    }
    @IBOutlet private weak var yearLabel: UILabel! {
        didSet {
            yearLabel.isHidden = yearLabel.text == nil
        }
    }

    // MARK: - Methods
    func configure(canSwitch: (left: Bool, right: Bool)) {
        toFirstButton.isEnabled = canSwitch.left
        toPreviousButton.isEnabled = canSwitch.left
        toNextButton.isEnabled = canSwitch.right
        toLastButton.isEnabled = canSwitch.right
    }

    func setLabels(month: String? = nil, year: String? = nil) {
        monthLabel.text = month
        yearLabel.text = year
    }
    
}
