//
//  WeightEntryPagerViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit
import SimpleAnimation

class WeightEntryPagerViewController: UIViewController {
    
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func newInstance(date: Date) -> WeightEntryPagerViewController {
        let storyboard = UIStoryboard(name: "WeightEntryPagerLayout", bundle: nil)
        guard
            let viewController = storyboard.instantiateViewController(withIdentifier: "WeightEntryPagerLayoutID") as? WeightEntryPagerViewController
            else { fatalError("Did not instantiate `WeightEntryPagerViewController`") }
        viewController.currentDate = date
        return viewController
    }

    @IBOutlet private weak var weightBackButton: UIButton!

    // MARK: - Properties

    /// 
    fileprivate var currentDate = DateManager.currentDatetime() {
        didSet {
            LogService.shared.debug("@DATE \(currentDate.datestampKey) WeightEntryPagerViewController")
        }
    }

    // MARK: - Outlets
    @IBOutlet private weak var weightDateButton: UIButton! {
        didSet {
            weightDateButton.layer.borderWidth = 1
            weightDateButton.layer.borderColor = weightDateButton.titleColor(for: .normal)?.cgColor
            weightDateButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet private weak var weightDatePicker: UIDatePicker! {
        didSet {
            weightDatePicker.maximumDate = DateManager.currentDatetime() // today
            
            if #available(iOS 13.4, *) {
                // Compact style with overlay
                weightDatePicker.preferredDatePickerStyle = .compact
                // After mode and style are set apply UIView sizeToFit().
                weightDatePicker.sizeToFit()
            }
        }
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white

        title = NSLocalizedString("weightEntry.heading", comment: "Weight entry heading")
        
        if currentDate.isInCurrentDayWith(DateManager.currentDatetime()) {
            weightBackButton.superview?.isHidden = true
            weightDateButton.setTitle(NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title"), for: .normal)
        } else {
            weightBackButton.superview?.isHidden = false
            weightDateButton.setTitle(currentDate.dateString(for: .long), for: .normal)
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
        if currentDate.isInCurrentDayWith(DateManager.currentDatetime()) {
            weightBackButton.superview?.isHidden = true
            weightDateButton.setTitle(NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title"), for: .normal)
        } else {
            weightBackButton.superview?.isHidden = false
            weightDateButton.setTitle(weightDatePicker.date.dateString(for: .long), for: .normal)
        }
        
        weightDatePicker.setDate(date, animated: false)

        guard let viewController = children.first as? WeightEntryViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(viewDate: currentDate)
    }

    // MARK: - Actions
    @IBAction private func weightDateButtonPressed(_ sender: UIButton) {
        weightDatePicker.isHidden = false
        weightDatePicker.maximumDate = DateManager.currentDatetime() // today
        weightDateButton.isHidden = true
    }

    @IBAction private func dateChanged(_ sender: UIDatePicker) {
        weightDateButton.isHidden = false
        weightDatePicker.isHidden = true
        weightDatePicker.maximumDate = DateManager.currentDatetime() // today
        currentDate = weightDatePicker.date
        if currentDate.isInCurrentDayWith(DateManager.currentDatetime()) {
            weightBackButton.superview?.isHidden = true
            weightDateButton.setTitle(NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title"), for: .normal)
        } else {
            weightBackButton.superview?.isHidden = false
            weightDateButton.setTitle(weightDatePicker.date.dateString(for: .long), for: .normal)
        }

        guard let viewController = children.first as? WeightEntryViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(viewDate: weightDatePicker.date)
    }

    @IBAction private func viewSwiped(_ sender: UISwipeGestureRecognizer) {
        let today = DateManager.currentDatetime()
        let interval = sender.direction == .left ? -1 : 1
        guard let swipedDate = weightDatePicker.date.adding(.day, value: interval), 
              swipedDate <= today 
        else { return }

        weightDatePicker.setDate(swipedDate, animated: false)
        weightDatePicker.maximumDate = DateManager.currentDatetime() // today
        currentDate = weightDatePicker.date

        if currentDate.isInCurrentDayWith(DateManager.currentDatetime()) {
            weightBackButton.superview?.isHidden = true
            weightDateButton.setTitle(NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title"), for: .normal)
        } else {
            weightBackButton.superview?.isHidden = false
            weightDateButton.setTitle(weightDatePicker.date.dateString(for: .long), for: .normal)
        }

        guard let viewController = children.first as? WeightEntryViewController else { return }

        if sender.direction == .left {
            viewController.view.slideOut(x: -view.frame.width).slideIn(x: view.frame.width)
        } else {
            viewController.view.slideOut(x: view.frame.width).slideIn(x: -view.frame.width)
        }

        viewController.setViewModel(viewDate: weightDatePicker.date)
    }

    @IBAction private func backButtonPressed(_ sender: UIButton) {
        updateDate(DateManager.currentDatetime())
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
