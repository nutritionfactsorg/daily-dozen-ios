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
    
    /// Current display date
    private var currentDate = DateManager.currentDatetime() {
        didSet {
            if currentDate.isInCurrentDayWith(DateManager.currentDatetime()) {
                dozeBackButton.superview?.isHidden = true
                dozeDateButton.setTitle(NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title"), for: .normal)
            } else {
                dozeBackButton.superview?.isHidden = false
                dozeDateButton.setTitle(dozeDatePicker.date.dateString(for: .long), for: .normal)
            }
        }
    }

    // MARK: - Outlets
    
    @IBOutlet weak var dozeDateTextField: RoundedTextfield!
    
   private var dozeDateButton: UIButton! {
        didSet {
            dozeDateButton.layer.borderWidth = 1
            dozeDateButton.layer.borderColor = dozeDateButton.titleColor(for: .normal)?.cgColor
            dozeDateButton.layer.cornerRadius = 5
        }
    }
    
    private var dozeDatePicker: UIDatePicker! {
        didSet {
            dozeDatePicker.maximumDate = DateManager.currentDatetime() // today
            
            if #available(iOS 13.4, *) {
                // Compact style with overlay
                dozeDatePicker.preferredDatePickerStyle = .wheels
                // After mode and style are set apply UIView sizeToFit().
                dozeDatePicker.sizeToFit()
            }
        }
    }

    @IBOutlet private weak var dozeBackButton: UIButton!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white

        title = NSLocalizedString("navtab.doze", comment: "Daily Dozen (proper noun) navigation tab")
        
        dozeDatePicker = UIDatePicker() // :TBD:???: add min-max contraints?
        dozeDatePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            // Expressly use inline wheel (UIPickerView) style.
            dozeDatePicker.preferredDatePickerStyle = .wheels
            dozeDatePicker.sizeToFit()
        }
        // :!!!:???: live change vs. change at dismiss
        dozeDatePicker.addTarget(self, action: #selector(DozeEntryPagerViewController.dozeDateChanged(dozeDatePicker:)), for: .valueChanged)
        
        //timeAMInput.inputView = timePickerAM // assign initial value
        //dozeDateButton.addAction(<#T##action: UIAction##UIAction#>, for: <#T##UIControl.Event#>)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        if UserDefaults.standard.bool(forKey: SettingsKeys.hasSeenFirstLaunch) == false {
            UserDefaults.standard.set(true, forKey: SettingsKeys.hasSeenFirstLaunch)
            let viewController = FirstLaunchViewController.newInstance()
            navigationController?.pushViewController(viewController, animated: true)
        }

    }

    // MARK: - Methods
    /// Updates UI for the current date.
    ///
    /// - Parameter date: The current date.
    func updateDate(_ date: Date) {
        currentDate = date
        dozeDatePicker.setDate(date, animated: false)

        guard let viewController = children.first as? DozeEntryViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(date: currentDate)
    }

    // MARK: - Actions
    @IBAction private func dozeDateButtonPressed(_ sender: UIButton) {
        dozeDatePicker.isHidden = false
        dozeDatePicker.maximumDate = DateManager.currentDatetime() // today
        
        // :!!!:???:

    }

    // :WIP:
    
    //var datePicker: UIDatePicker?
    //func showDatePicker() {
    //    datePicker = UIDatePicker()
    //    datePicker?.date = Date()
    //    datePicker?.locale = .current
    //    if #available(iOS 13.4, *) {
    //        datePicker?.preferredDatePickerStyle = .compact
    //    } else {
    //        // Fallback on earlier versions
    //    }
    //    datePicker?.addTarget(self, action: #selector(handleDateSelection), for: .valueChanged)
    //}

    @objc private func dozeDateChanged(dozeDatePicker: UIDatePicker) {
        dozeDateButton.isHidden = false
        dozeDatePicker.isHidden = true
        dozeDatePicker.maximumDate = DateManager.currentDatetime() // today
        currentDate = dozeDatePicker.date

        guard let viewController = children.first as? DozeEntryViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(date: dozeDatePicker.date)
    }

    @IBAction private func viewSwiped(_ sender: UISwipeGestureRecognizer) {
        let today = DateManager.currentDatetime()
        let interval = sender.direction == .left ? -1 : 1
        guard let swipedDate = dozeDatePicker.date.adding(.day, value: interval), 
              swipedDate <= today 
        else { return }

        dozeDatePicker.setDate(swipedDate, animated: false)
        dozeDatePicker.maximumDate = DateManager.currentDatetime() // today
        currentDate = dozeDatePicker.date

        guard let viewController = children.first as? DozeEntryViewController else { return }

        if sender.direction == .left {
            viewController.view.slideOut(x: -view.frame.width).slideIn(x: view.frame.width)
        } else {
            viewController.view.slideOut(x: view.frame.width).slideIn(x: -view.frame.width)
        }

        viewController.setViewModel(date: dozeDatePicker.date)
    }

    @IBAction private func dozeBackButtonPressed(_ sender: UIButton) {
        updateDate(DateManager.currentDatetime())
    }
}

extension DozeEntryPagerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
}

extension DozeEntryPagerViewController: UIPickerViewDelegate {
    
}
