//
//  ServingsPagerViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import SimpleAnimation

// MARK: - Builder

class ServingsPagerBuilder {

    // MARK: - Nested
    struct Keys {
        static let storyboard = "ServingsPager"
    }

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> UIViewController {
        let storyboard = UIStoryboard(name: Keys.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController()
            else { fatalError("Did not instantiate `ServingsPager` controller") }

        return viewController
    }
}

// MARK: - Controller
class ServingsPagerViewController: UIViewController {

    // MARK: - Properties
    private var currentDate = Date() {
        didSet {
            if currentDate.isInCurrentDayWith(Date()) {
                backButton.superview?.isHidden = true
                dateButton.setTitle("Today", for: .normal)
            } else {
                backButton.superview?.isHidden = false
                dateButton.setTitle(datePicker.date.dateString(for: .long), for: .normal)
            }
        }
    }

    // MARK: - Outlets
    @IBOutlet private weak var dateButton: UIButton! {
        didSet {
            dateButton.layer.borderWidth = 1
            dateButton.layer.borderColor = dateButton.titleColor(for: .normal)?.cgColor
            dateButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet private weak var datePicker: UIDatePicker! {
        didSet {
            datePicker.maximumDate = Date()
        }
    }

    @IBOutlet private weak var backButton: UIButton!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Daily Dozen"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        if !UserDefaults.standard.bool(forKey: SettingsKeys.hasSeenFirstLaunch) == false {
            UserDefaults.standard.set(true, forKey: SettingsKeys.hasSeenFirstLaunch)
            let viewController = FirstLaunchBuilder.instantiateController()
            navigationController?.pushViewController(viewController, animated: true)
        }

    }

    // MARK: - Methods
    /// Updates UI for the current date.
    ///
    /// - Parameter date: The current date.
    func updateDate(_ date: Date) {
        currentDate = date
        datePicker.setDate(date, animated: false)

        guard let viewController = children.first as? ServingsViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(for: currentDate)
    }

    // MARK: - Actions
    @IBAction private func dateButtonPressed(_ sender: UIButton) {
        datePicker.isHidden = false
        dateButton.isHidden = true
    }

    @IBAction private func dateChanged(_ sender: UIDatePicker) {
        dateButton.isHidden = false
        datePicker.isHidden = true
        currentDate = datePicker.date

        guard let viewController = children.first as? ServingsViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(for: datePicker.date)
    }

    @IBAction private func viewSwipped(_ sender: UISwipeGestureRecognizer) {
        let interval = sender.direction == .left ? -1 : 1
        let currentDate = datePicker.date.adding(.day, value: interval)

        let today = Date()

        guard let date = currentDate, date <= today else { return }

        datePicker.setDate(date, animated: false)

        self.currentDate = datePicker.date

        guard let viewController = children.first as? ServingsViewController else { return }

        if sender.direction == .left {
            viewController.view.slideOut(x: -view.frame.width).slideIn(x: view.frame.width)
        } else {
            viewController.view.slideOut(x: view.frame.width).slideIn(x: -view.frame.width)
        }

        viewController.setViewModel(for: datePicker.date)
    }

    @IBAction private func backButtonPressed(_ sender: UIButton) {
        updateDate(Date())
    }
}
