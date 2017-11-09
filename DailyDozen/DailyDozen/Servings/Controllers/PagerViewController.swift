//
//  PagerViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class PagerViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var dateButton: UIButton!
    @IBOutlet private weak var datePicker: UIDatePicker! {
        didSet {
            datePicker.maximumDate = Date()
        }
    }

    // MARK: - Propeties
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale.current
        return formatter
    }()

    // MARK: - Actions
    @IBAction private func dateButtonPressed(_ sender: UIButton) {
        datePicker.isHidden = false
        dateButton.isHidden = true
    }

    @IBAction private func dateChanged(_ sender: UIDatePicker) {
        dateButton.setTitle(dateFormatter.string(from: datePicker.date), for: .normal)
        dateButton.isHidden = false
        datePicker.isHidden = true
    }
}
