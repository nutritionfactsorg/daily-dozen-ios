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
        viewController.weightPageDate = date
        return viewController
    }
        
    // MARK: - Properties
    
    /// Current page display date "truth"
    fileprivate var weightPageDate = DateManager.currentDatetime()
    
    // MARK: - Outlets
    
    @IBOutlet private weak var weightBackButton: UIButton!
    @IBOutlet weak var weightDateBarField: RoundedTextfield!    
    private var weightDateBarPicker: UIDatePicker!
        
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navBar = navigationController?.navigationBar {
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navBar.barTintColor = UIColor.greenColor
            navBar.tintColor = UIColor.white            
        }
        
        title = NSLocalizedString("weightEntry.heading", comment: "Weight entry heading")
        
        weightDateBarPicker = weightDateBarField.datePicker(
            target: self, 
            cancelAction: #selector(weightDateBarCancelAction), 
            doneAction: #selector(weightDateBarDoneAction), 
            todayAction: #selector(weightDateBarTodayAction)
        )
        weightDateBarField.addTarget(self, action: #selector(dateBarTouchDown), for: .touchDown)
        updatePageDate(weightPageDate)
    }
    
    @objc func weightDateBarCancelAction() {
        updatePageDate(weightPageDate) // same date
        self.weightDateBarField.resignFirstResponder()
    }
    
    @objc func weightDateBarDoneAction() {
        updatePageDate(weightDateBarPicker.date)
        self.weightDateBarField.resignFirstResponder()
    }
    
    @objc func weightDateBarTodayAction() {
        updatePageDate(DateManager.currentDatetime())
        self.weightDateBarField.resignFirstResponder()
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
    func updatePageDate(_ date: Date) {
        let order = Calendar.current.compare(date, to: weightPageDate, toGranularity: .day)
        weightPageDate = date
        weightDateBarPicker.setDate(weightPageDate, animated: false)
        weightDateBarPicker.maximumDate = DateManager.currentDatetime()
        
        if weightPageDate.isInCurrentDayWith(DateManager.currentDatetime()) {
            weightBackButton.superview?.isHidden = true
            weightDateBarField.text = NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title")
        } else {
            weightBackButton.superview?.isHidden = false
            weightBackButton.setTitle(NSLocalizedString("dateBackButtonTitle", comment: "Back to today"), for: UIControl.State.normal)
            weightDateBarField.text = weightDateBarPicker.date.dateStringLocalized(for: .long)
        }
        
        if order != .orderedSame {
            guard let viewController = children.first as? WeightEntryViewController else { return }
            viewController.view.fadeOut().fadeIn()
            viewController.setViewModel(date: weightPageDate)
        }
    }
    
    // MARK: - Actions
    
    @objc private func dateBarTouchDown(_ sender: UITextField) {
        weightDateBarField.text = weightDateBarPicker.date.dateStringLocalized(for: .long)
        weightDateBarPicker.maximumDate = DateManager.currentDatetime() // today
    }
        
    @IBAction private func viewSwiped(_ sender: UISwipeGestureRecognizer) {
        let today = DateManager.currentDatetime()
        let interval = sender.direction == .left ? -1 : 1
        let swipedDate = weightDateBarPicker.date.adding(days: interval)
        guard swipedDate <= today else { return }
        
        weightDateBarPicker.setDate(swipedDate, animated: false)
        weightDateBarPicker.maximumDate = DateManager.currentDatetime() // today
        updatePageDate(weightDateBarPicker.date)
                
        guard let viewController = children.first as? DozeEntryViewController else { return }
        
        if sender.direction == .left {
            viewController.view.slideOut(x: -view.frame.width).slideIn(x: view.frame.width)
        } else {
            viewController.view.slideOut(x: view.frame.width).slideIn(x: -view.frame.width)
        }
        
        viewController.setViewModel(date: weightDateBarPicker.date)
    }
    
    @IBAction private func weightBackButtonPressed(_ sender: UIButton) {
        updatePageDate(DateManager.currentDatetime())
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "weightEditEmbedSegue" {
            if let childVC = segue.destination as? WeightEntryViewController {
                //Some property on ChildVC that needs to be set
                childVC.currentViewDateWeightEntry = weightPageDate
            }
        }
    }
    
}
