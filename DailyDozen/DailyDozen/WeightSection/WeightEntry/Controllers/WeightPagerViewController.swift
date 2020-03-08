//
//  WeightPagerViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit
import SimpleAnimation

// MARK: - Builder

class WeightPagerBuilder {

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> UIViewController {
        let storyboard = UIStoryboard(name: "WeightPagerLayout", bundle: nil)
        guard
            let viewController = storyboard.instantiateInitialViewController()
            else { fatalError("Did not instantiate `WeightPagerViewController`") }

        return viewController
    }
}

// MARK: - Controller
class WeightPagerViewController: UIViewController {

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
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white

        title = "Weight"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    // MARK: - Methods
    /// Updates UI for the current date.
    ///
    /// - Parameter date: The current date.
    func updateDate(_ date: Date) {
        currentDate = date
        datePicker.setDate(date, animated: false)

        guard let viewController = children.first as? WeightViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(viewDate: currentDate)
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

        guard let viewController = children.first as? WeightViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(viewDate: datePicker.date)
    }

    @IBAction private func viewSwipped(_ sender: UISwipeGestureRecognizer) {
        let interval = sender.direction == .left ? -1 : 1
        let currentDate = datePicker.date.adding(.day, value: interval)

        let today = Date()

        guard let date = currentDate, date <= today else { return }

        datePicker.setDate(date, animated: false)

        self.currentDate = datePicker.date

        guard let viewController = children.first as? WeightViewController else { return }

        if sender.direction == .left {
            viewController.view.slideOut(x: -view.frame.width).slideIn(x: view.frame.width)
        } else {
            viewController.view.slideOut(x: view.frame.width).slideIn(x: -view.frame.width)
        }

        viewController.setViewModel(viewDate: datePicker.date)
    }

    @IBAction private func backButtonPressed(_ sender: UIButton) {
        updateDate(Date())
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
