//
//  DozeEntryPagerViewController.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import SimpleAnimation

class DozeEntryPagerViewController: UIViewController {
    
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func newInstance() -> UIViewController {
        let storyboard = UIStoryboard(name: "DozeEntryPagerLayout", bundle: nil)
        guard
            let viewController = storyboard.instantiateInitialViewController()
        else { fatalError("Did not instantiate `DozeEntryPagerViewController`") }
        
        return viewController
    }
    
    // MARK: - Properties
    
    /// Current page display date "truth"
    private var dozePageDate = DateManager.currentDatetime()
        
    // MARK: - Outlets
    
    @IBOutlet private weak var dozeBackButton: UIButton!
    @IBOutlet weak var dozeBackRoundedView: RoundedView!
    @IBOutlet weak var dozeDateBarField: RoundedTextfield!    
    private var dozeDateBarPicker: UIDatePicker!
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navBar = navigationController?.navigationBar {            
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navBar.barTintColor = ColorManager.style.mainMedium
            navBar.tintColor = UIColor.white
            navBar.backgroundColor = ColorManager.style.mainMedium
        }
        
        title = NSLocalizedString("navtab.doze", comment: "Daily Dozen (proper noun) navigation tab")
        
        dozeBackRoundedView.backgroundColor = ColorManager.style.mainMedium
        
        dozeDateBarPicker = dozeDateBarField.datePicker(
            target: self, 
            cancelAction: #selector(dozeDateBarCancelAction), 
            doneAction: #selector(dozeDateBarDoneAction), 
            todayAction: #selector(dozeDateBarTodayAction)
        )
        dozeDateBarField.backgroundColor = ColorManager.style.mainMedium
        dozeDateBarField.tintColor = ColorManager.style.mainMedium
        dozeDateBarField.textColor = ColorManager.style.textWhite
        dozeDateBarField.addTarget(self, action: #selector(dateBarTouchDown), for: .touchDown)
        updatePageDate(DateManager.currentDatetime())
    }
    
    @objc func dozeDateBarCancelAction() {
        updatePageDate(dozePageDate) // same date
        self.dozeDateBarField.resignFirstResponder()
    }
    
    @objc func dozeDateBarDoneAction() {
        updatePageDate(dozeDateBarPicker.date)
        self.dozeDateBarField.resignFirstResponder()
    }
    
    @objc func dozeDateBarTodayAction() {
        updatePageDate(DateManager.currentDatetime())
        self.dozeDateBarField.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barTintColor = ColorManager.style.mainMedium
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        // If key doesn‘t exist, this UserDefaults method returns false.
        if UserDefaults.standard.bool(forKey: SettingsKeys.hasSeenFirstLaunch) == false {
            UserDefaults.standard.set(true, forKey: SettingsKeys.hasSeenFirstLaunch)
            let viewController = FirstLaunchViewController.newInstance()
            navigationController?.pushViewController(viewController, animated: true)
        }
        
        if UserDefaults.standard.object(forKey: SettingsKeys.analyticsIsEnabledPref) == nil {
            #if DEBUG || QA 
            
            #else
            
            #endif
            
            #if WITH_ANALYTICS
            let alert = GoogleAnalyticsHelper.shared.buildAnalyticsConsentAlert()
            present(alert, animated: true, completion: nil)
            #else
            #endif
        }
    }
    
    // MARK: - Methods
    
    /// Updates UI for the current date.
    ///
    /// - Parameter date: The current date.
    func updatePageDate(_ date: Date) {
        let order = Calendar.current.compare(date, to: dozePageDate, toGranularity: .day)
        dozePageDate = date
        dozeDateBarPicker.setDate(dozePageDate, animated: false)
        dozeDateBarPicker.maximumDate = DateManager.currentDatetime()
        
        if dozePageDate.isInCurrentDayWith(DateManager.currentDatetime()) {
            dozeBackButton.superview?.isHidden = true
            dozeDateBarField.text = NSLocalizedString("dateButtonTitle.today", comment: "Date Button Title: 'Today'")
        } else {
            dozeBackButton.superview?.isHidden = false
            dozeBackButton.setTitle(NSLocalizedString("dateBackButtonTitle", comment: "Date Button Title: 'Back to today'"), for: UIControl.State.normal)
            dozeDateBarField.text = dozeDateBarPicker.date.dateStringLocalized(for: .long)
        }
        
        if order != .orderedSame {
            guard let viewController = children.first as? DozeEntryViewController else { return }
            viewController.view.fadeOut().fadeIn()
            viewController.setViewModel(date: dozePageDate)
        }
    }
    
    // MARK: - Actions
    
    @objc private func dateBarTouchDown(_ sender: UITextField) {
        dozeDateBarField.text = dozeDateBarPicker.date.dateStringLocalized(for: .long)
        dozeDateBarPicker.maximumDate = DateManager.currentDatetime() // today
    }
    
    @IBAction private func viewSwiped(_ sender: UISwipeGestureRecognizer) {
        let today = DateManager.currentDatetime()
        let interval = sender.direction == .left ? -1 : 1
        let swipedDate = dozeDateBarPicker.date.adding(days: interval)
        guard swipedDate <= today else { return }
        
        dozeDateBarPicker.setDate(swipedDate, animated: false)
        dozeDateBarPicker.maximumDate = DateManager.currentDatetime() // today
        updatePageDate(dozeDateBarPicker.date) 
        
        guard let viewController = children.first as? DozeEntryViewController else { return }
        
        if sender.direction == .left {
            viewController.view.slideOut(x: -view.frame.width).slideIn(x: view.frame.width)
        } else {
            viewController.view.slideOut(x: view.frame.width).slideIn(x: -view.frame.width)
        }
        
        viewController.setViewModel(date: dozeDateBarPicker.date)
    }
    
    @IBAction private func dozeBackButtonPressed(_ sender: UIButton) {
        updatePageDate(DateManager.currentDatetime())
    }
}
