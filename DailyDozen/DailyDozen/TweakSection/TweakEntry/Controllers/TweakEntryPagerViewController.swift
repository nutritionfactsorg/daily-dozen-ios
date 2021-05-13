//
//  TweakEntryPagerViewController.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import SimpleAnimation

// MARK: - Controller
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
    
    /// Current page display date "truth"
    private var tweakPageDate = DateManager.currentDatetime()

    // MARK: - Outlets
    
    @IBOutlet private weak var tweakBackButton: UIButton!
    @IBOutlet weak var tweakDateBarField: RoundedTextfield!
    private var tweakDateBarPicker: UIDatePicker!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navBar = navigationController?.navigationBar {
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navBar.barTintColor = ColorManager.style.mainMedium
            navBar.tintColor = UIColor.white            
        }

        title = NSLocalizedString("navtab.tweaks", comment: "21 Tweaks (proper noun) navigation tab")
        
        tweakDateBarPicker = tweakDateBarField.datePicker(
            target: self, 
            cancelAction: #selector(tweakDateBarCancelAction), 
            doneAction: #selector(tweakDateBarDoneAction), 
            todayAction: #selector(tweakDateBarTodayAction)
        )
        tweakDateBarField.addTarget(self, action: #selector(dateBarTouchDown), for: .touchDown)
        updatePageDate(DateManager.currentDatetime())
    }

    @objc func tweakDateBarCancelAction() {
        updatePageDate(tweakPageDate) // same date
        self.tweakDateBarField.resignFirstResponder()
    }
    
    @objc func tweakDateBarDoneAction() {
        updatePageDate(tweakDateBarPicker.date)
        self.tweakDateBarField.resignFirstResponder()
    }
    
    @objc func tweakDateBarTodayAction() {
        updatePageDate(DateManager.currentDatetime())
        self.tweakDateBarField.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.navigationBar.barTintColor = ColorManager.style.mainMedium
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    // MARK: - Methods
    
    /// Updates UI for the current date.
    ///
    /// - Parameter date: The current date.
    func updatePageDate(_ date: Date) {
        let order = Calendar.current.compare(date, to: tweakPageDate, toGranularity: .day)
        tweakPageDate = date
        tweakDateBarPicker.setDate(tweakPageDate, animated: false)
        tweakDateBarPicker.maximumDate = DateManager.currentDatetime()
        
        if tweakPageDate.isInCurrentDayWith(DateManager.currentDatetime()) {
            tweakBackButton.superview?.isHidden = true
            tweakDateBarField.text = NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title")
        } else {
            tweakBackButton.superview?.isHidden = false
            tweakBackButton.setTitle(NSLocalizedString("dateBackButtonTitle", comment: "Back to today"), for: UIControl.State.normal)
            tweakDateBarField.text = tweakDateBarPicker.date.dateStringLocalized(for: .long)
        }
        
        if order != .orderedSame {
            guard let viewController = children.first as? TweakEntryViewController else { return }
            viewController.view.fadeOut().fadeIn()
            viewController.setViewModel(date: tweakPageDate)
        }
    }

    // MARK: - Actions

    @objc private func dateBarTouchDown(_ sender: UITextField) {
        tweakDateBarField.text = tweakDateBarPicker.date.dateStringLocalized(for: .long)
        tweakDateBarPicker.maximumDate = DateManager.currentDatetime() // today
    }

    @IBAction private func viewSwiped(_ sender: UISwipeGestureRecognizer) {
        let today = DateManager.currentDatetime()
        let interval = sender.direction == .left ? -1 : 1
        let swipedDate = tweakDateBarPicker.date.adding(days: interval)
        guard swipedDate <= today else { return }

        tweakDateBarPicker.setDate(swipedDate, animated: false)
        tweakDateBarPicker.maximumDate = DateManager.currentDatetime() // today
        updatePageDate(tweakDateBarPicker.date)

        guard let viewController = children.first as? TweakEntryViewController else { return }

        if sender.direction == .left {
            viewController.view.slideOut(x: -view.frame.width).slideIn(x: view.frame.width)
        } else {
            viewController.view.slideOut(x: view.frame.width).slideIn(x: -view.frame.width)
        }

        viewController.setViewModel(date: tweakDateBarPicker.date)
    }

    @IBAction private func tweakBackButtonPressed(_ sender: UIButton) {
        updatePageDate(DateManager.currentDatetime())
    }
}
