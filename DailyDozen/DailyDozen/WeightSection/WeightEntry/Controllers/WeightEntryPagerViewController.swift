//
//  WeightEntryPagerViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit
import SimpleAnimation

// MARK: - Builder

class WeightEntryPagerBuilder {

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController(date: Date) -> WeightEntryPagerViewController {
        let storyboard = UIStoryboard(name: "WeightEntryPagerLayout", bundle: nil)
        guard
            let viewController = storyboard.instantiateViewController(withIdentifier: "WeightEntryPagerLayoutID") as? WeightEntryPagerViewController
            else { fatalError("Did not instantiate `WeightEntryPagerViewController`") }
        viewController.currentDate = date
        return viewController
    }
}

// MARK: - Controller
class WeightEntryPagerViewController: UIViewController {
    
    @IBOutlet private weak var backButton: UIButton!

    // MARK: - Properties

    /// 
    fileprivate var currentDate = Date() {
        didSet {
            LogService.shared.debug("@DATE \(currentDate.datestampKey) WeightEntryPagerViewController")
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
            datePicker.maximumDate = Date() // today
        }
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white

        title = NSLocalizedString("weightEntry.heading", comment: "Weight entry heading")
        
        if currentDate.isInCurrentDayWith(Date()) {
            backButton.superview?.isHidden = true
            dateButton.setTitle(NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title"), for: .normal)
        } else {
            backButton.superview?.isHidden = false
            dateButton.setTitle(currentDate.dateString(for: .long), for: .normal)
        }
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
        if currentDate.isInCurrentDayWith(Date()) {
            backButton.superview?.isHidden = true
            dateButton.setTitle(NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title"), for: .normal)
        } else {
            backButton.superview?.isHidden = false
            dateButton.setTitle(datePicker.date.dateString(for: .long), for: .normal)
        }
        
        datePicker.setDate(date, animated: false)

        guard let viewController = children.first as? WeightEntryViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(viewDate: currentDate)
    }

    // MARK: - Actions
    @IBAction private func dateButtonPressed(_ sender: UIButton) {
        datePicker.isHidden = false
        datePicker.maximumDate = Date() // today
        dateButton.isHidden = true
    }

    @IBAction private func dateChanged(_ sender: UIDatePicker) {
        dateButton.isHidden = false
        datePicker.isHidden = true
        datePicker.maximumDate = Date() // today
        currentDate = datePicker.date
        if currentDate.isInCurrentDayWith(Date()) {
            backButton.superview?.isHidden = true
            dateButton.setTitle(NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title"), for: .normal)
        } else {
            backButton.superview?.isHidden = false
            dateButton.setTitle(datePicker.date.dateString(for: .long), for: .normal)
        }

        guard let viewController = children.first as? WeightEntryViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(viewDate: datePicker.date)
    }

    @IBAction private func viewSwiped(_ sender: UISwipeGestureRecognizer) {
        let today = Date()
        let interval = sender.direction == .left ? -1 : 1
        guard let swipedDate = datePicker.date.adding(.day, value: interval), 
              swipedDate <= today 
        else { return }

        datePicker.setDate(swipedDate, animated: false)
        datePicker.maximumDate = Date() // today
        currentDate = datePicker.date

        if currentDate.isInCurrentDayWith(Date()) {
            backButton.superview?.isHidden = true
            dateButton.setTitle(NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title"), for: .normal)
        } else {
            backButton.superview?.isHidden = false
            dateButton.setTitle(datePicker.date.dateString(for: .long), for: .normal)
        }

        guard let viewController = children.first as? WeightEntryViewController else { return }

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

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "weightEditEmbedSegue" {
            if let childVC = segue.destination as? WeightEntryViewController {
                //Some property on ChildVC that needs to be set
                childVC.currentViewDateWeightEntry = currentDate
            }
        }
    }
    
}
