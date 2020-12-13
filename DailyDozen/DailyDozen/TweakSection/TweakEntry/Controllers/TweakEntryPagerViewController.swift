//
//  TweakEntryPagerViewController.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import SimpleAnimation

class TweakEntryPagerViewController: UIViewController {

    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func newInstance() -> UIViewController {
        let storyboard = UIStoryboard(name: "TweakEntryPagerLayout", bundle: nil)
        guard
            let viewController = storyboard.instantiateInitialViewController()
            else { fatalError("Did not instantiate `TweakEntryPagerViewController`") }

        return viewController
    }

    // MARK: - Properties
    private var currentDate = DateManager.currentDatetime() {
        didSet {
            LogService.shared.debug("@DATE \(currentDate.datestampKey) TweakEntryPagerViewController")
            if currentDate.isInCurrentDayWith(DateManager.currentDatetime()) {
                tweakBackButton.superview?.isHidden = true
                tweakDateButton.setTitle(NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title"), for: .normal)
            } else {
                tweakBackButton.superview?.isHidden = false
                tweakDateButton.setTitle(tweakDatePicker.date.dateString(for: .long), for: .normal)
            }
        }
    }

    // MARK: - Outlets
    @IBOutlet private weak var tweakDateButton: UIButton! {
        didSet {
            tweakDateButton.layer.borderWidth = 1
            tweakDateButton.layer.borderColor = tweakDateButton.titleColor(for: .normal)?.cgColor
            tweakDateButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet private weak var tweakDatePicker: UIDatePicker! {
        didSet {
            tweakDatePicker.maximumDate = DateManager.currentDatetime() // today
            
            if #available(iOS 13.4, *) {
                // Compact style with overlay
                tweakDatePicker.preferredDatePickerStyle = .compact
                // After mode and style are set apply UIView sizeToFit().
                tweakDatePicker.sizeToFit()
            }
        }
    }

    @IBOutlet private weak var tweakBackButton: UIButton!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white

        title = NSLocalizedString("navtab.tweaks", comment: "21 Tweaks (proper noun) navigation tab")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    // MARK: - Methods
    /// Updates UI for the current date.
    ///
    /// - Parameter date: The current date.
    func updateDate(_ date: Date) {
        currentDate = date
        tweakDatePicker.setDate(date, animated: false)

        guard let viewController = children.first as? TweakEntryViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(date: currentDate)
    }

    // MARK: - Actions
    @IBAction private func tweakDateButtonPressed(_ sender: UIButton) {
        tweakDatePicker.isHidden = false
        tweakDatePicker.maximumDate = DateManager.currentDatetime() // today
        tweakDateButton.isHidden = true
    }

    @IBAction private func dateChanged(_ sender: UIDatePicker) {
        tweakDateButton.isHidden = false
        tweakDatePicker.isHidden = true
        tweakDatePicker.maximumDate = DateManager.currentDatetime() // today
        currentDate = tweakDatePicker.date

        guard let viewController = children.first as? TweakEntryViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(date: tweakDatePicker.date)
    }

    @IBAction private func viewSwiped(_ sender: UISwipeGestureRecognizer) {
        let today = DateManager.currentDatetime()
        let interval = sender.direction == .left ? -1 : 1
        guard let swipedDate = tweakDatePicker.date.adding(.day, value: interval), 
              swipedDate <= today 
        else { return }

        tweakDatePicker.setDate(swipedDate, animated: false)
        tweakDatePicker.maximumDate = DateManager.currentDatetime() // today
        currentDate = tweakDatePicker.date

        guard let viewController = children.first as? TweakEntryViewController else { return }

        if sender.direction == .left {
            viewController.view.slideOut(x: -view.frame.width).slideIn(x: view.frame.width)
        } else {
            viewController.view.slideOut(x: view.frame.width).slideIn(x: -view.frame.width)
        }

        viewController.setViewModel(date: tweakDatePicker.date)
    }

    @IBAction private func tweakBackButtonPressed(_ sender: UIButton) {
        updateDate(DateManager.currentDatetime())
    }
}
