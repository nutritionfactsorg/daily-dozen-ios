//
//  SettingsViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsViewController: UITableViewController {
    
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func newInstance() -> SettingsViewController {
        let storyboard = UIStoryboard(name: "SettingsLayout", bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? SettingsViewController
        else { fatalError("Did not instantiate `SettingsViewController`") }
        viewController.title = NSLocalizedString("navtab.preferences", comment: "Preferences (aka Settings, Configuration) navigation tab. Choose word different from 'Tweaks' translation")
        
        return viewController
    }
    
    /// Measurement Units
    @IBOutlet weak var unitMeasureToggle: UISegmentedControl!
    /// Daily Reminder
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var reminderIsOn: UILabel!
    /// 21 Tweaks Visibility
    @IBOutlet weak var tweakVisibilityController: UISegmentedControl!
    
    // Advance Utilities
    @IBOutlet weak var advancedUtilitiesTableViewCell: UITableViewCell!
    
    enum UnitsSegmentState: Int {
        case imperialState = 0
        case metricState = 1
        case toggleUnitsState = 2
    }
    
    var reminderSwitch: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = ColorManager.style.mainMedium
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // Measurement Units
        unitMeasureToggle.tintColor = ColorManager.style.mainMedium
        setUnitsMeasureSegment()
        
        // Reminder
        let canNotificate = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)
        if canNotificate {
            reminderIsOn.text = NSLocalizedString("reminder.state.on", comment: "'On' as in 'On or Off'")
        } else {
            reminderIsOn.text = NSLocalizedString("reminder.state.off", comment: "'Off' as in 'On or Off'")
        }
        reminderLabel.text = NSLocalizedString("reminder.settings.enable", comment: "Enable Reminders")
        
        // 21 Tweaks Visibility
        tweakVisibilityController.tintColor = ColorManager.style.mainMedium
        if UserDefaults.standard.bool(forKey: SettingsKeys.show21TweaksPref) {
            tweakVisibilityController.selectedSegmentIndex = 1
        } else {
            tweakVisibilityController.selectedSegmentIndex = 0
        }
        
        #if targetEnvironment(simulator)
        // LogService.shared.debug("::::: SIMULATOR ENVIRONMENT: SettingsViewController :::::")
        advancedUtilitiesTableViewCell.isHidden = false
        // LogService.shared.debug(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n")
        #endif
        #if DEBUG
        advancedUtilitiesTableViewCell.isHidden = false
        #endif
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let canNotificate = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)
        if canNotificate {
            reminderIsOn.text = NSLocalizedString("reminder.state.on", comment: "'On' as in 'On or Off'")
        } else {
            reminderIsOn.text = NSLocalizedString("reminder.state.off", comment: "'Off' as in 'On or Off'")
        }
    }
    
    func setUnitsMeasureSegment() {
        let shouldShowUnitsToggle = UserDefaults.standard.bool(forKey: SettingsKeys.unitsTypeToggleShowPref)
        guard let unitTypePrefStr =  UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
              let unitTypePref = UnitsType(rawValue: unitTypePrefStr)
        else { return } // :!!!:MEC:review
        if  shouldShowUnitsToggle == true {
            unitMeasureToggle.selectedSegmentIndex = UnitsSegmentState.toggleUnitsState.rawValue
        } else {
            if unitTypePref == .imperial {
                unitMeasureToggle.selectedSegmentIndex = UnitsSegmentState.imperialState.rawValue
            }
            if unitTypePref == .metric {
                unitMeasureToggle.selectedSegmentIndex = UnitsSegmentState.metricState.rawValue
            }
        }
    }
    
    @IBAction func unitsTypePrefChanged(_ sender: UISegmentedControl) {
        // let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
        var prefUnitTypeString = ""
        var prefShowToggle = false
        let isImperialInitialValue = SettingsManager.isImperial()
        switch unitMeasureToggle.selectedSegmentIndex {
        case UnitsSegmentState.imperialState.rawValue:
            prefUnitTypeString = UnitsType.imperial.rawValue // "imperial"
            prefShowToggle = false
        case UnitsSegmentState.metricState.rawValue:
            prefUnitTypeString = UnitsType.metric.rawValue // "metric"
            prefShowToggle = false
        case UnitsSegmentState.toggleUnitsState.rawValue:
            if let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref) {
                // Existing preference
                prefUnitTypeString = unitsTypePrefStr
            } else {
                // Unstated pref defaults to imperial. 
                // :TBD:ToBeLocalized: set initial default based on device language
                prefUnitTypeString = UnitsType.imperial.rawValue // "imperial"
            }
            prefShowToggle = true
        default:
            break
        }
        UserDefaults.standard.set(prefShowToggle, forKey: SettingsKeys.unitsTypeToggleShowPref)
        UserDefaults.standard.set(prefUnitTypeString, forKey: SettingsKeys.unitsTypePref)
        let isImperialCurrentValue = SettingsManager.isImperial()
        if isImperialInitialValue != isImperialCurrentValue {
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "NoticeChangedUnitsType"),
                object: isImperialCurrentValue,
                userInfo: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func doTweaksVisibilityChanged(_ sender: UISegmentedControl) {
        // LogService.shared.debug("selectedSegmentIndex = \(segmentedControl.selectedSegmentIndex)")
        let show21Tweaks = UserDefaults.standard.bool(forKey: SettingsKeys.show21TweaksPref)
        if tweakVisibilityController.selectedSegmentIndex == 0
            && show21Tweaks {
            // Toggle to hide 2nd tab
            UserDefaults.standard.set(false, forKey: SettingsKeys.show21TweaksPref)
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "NoticeUpdatedShowTweaksTab"),
                object: 2, // Dozen, More, Settings
                userInfo: nil)
        } else if tweakVisibilityController.selectedSegmentIndex == 1
                    && show21Tweaks == false {
            // Toggle to show 2nd tab
            UserDefaults.standard.set(true, forKey: SettingsKeys.show21TweaksPref)
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "NoticeUpdatedShowTweaksTab"),
                object: 3, // Dozen, Tweaks, More, Settings
                userInfo: nil)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Utilities
    
    @IBAction func doUtilityShowAdvancedBtn(_ sender: UIButton) {
        let viewController = UtilityTableViewController.newInstance()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        switch section {
        case 0: // IFs-g0-SPV.headerTitle
            sectionName = NSLocalizedString("settings.units.header", comment: "Measurement Units")
        case 1: // GiY-ao-2ee.headerTitle
            sectionName = NSLocalizedString("reminder.heading", comment: "Daily Reminder")
        case 2: // WdR-XV-IyP.headerTitle
            sectionName = NSLocalizedString("settings.tweak.header", comment: "21 Tweaks Visibility")
        case 3: // Bx8-EJ-3BK.headerTitle Developer Extras
            sectionName = ""
        default:
            sectionName = ""
        }
        return sectionName
    }
    
}
