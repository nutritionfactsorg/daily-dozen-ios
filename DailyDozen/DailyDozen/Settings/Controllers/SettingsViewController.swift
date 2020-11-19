//
//  SettingsViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit
import UserNotifications

// MARK: - Builder
class SettingsBuilder {
    
    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> SettingsViewController {
        let storyboard = UIStoryboard(name: "SettingsLayout", bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? SettingsViewController
            else { fatalError("Did not instantiate `SettingsViewController`") }
        viewController.title = NSLocalizedString("navtab.preferences", comment: "Preferences (aka Settings, Configuration) navigation tab. Choose word different from 'Tweaks' translation")
        
        return viewController
    }
}

class SettingsViewController: UITableViewController {
    
    // Measurement Units
    @IBOutlet weak var unitMeasureToggle: UISegmentedControl!
    // Daily Reminder
    @IBOutlet weak var reminderIsOn: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    // @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var soundSwitch: UISwitch!
    // 21 Tweaks Visibility
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
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // Measurement Units
        setUnitsMeasureSegment()
        
        // Reminder
        let canNotificate = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)
        if canNotificate {
            reminderIsOn.text = "On"
        } else {
            reminderIsOn.text = "Off"
        }
        
        // 21 Tweaks Visibility
        if UserDefaults.standard.bool(forKey: SettingsKeys.show21TweaksPref) {
            tweakVisibilityController.selectedSegmentIndex = 1
        } else {
            tweakVisibilityController.selectedSegmentIndex = 0
        }
        
        #if targetEnvironment(simulator)
        //LogService.shared.debug("::::: SIMULATOR ENVIRONMENT: SettingsViewController :::::")
        advancedUtilitiesTableViewCell.isHidden = false
        //LogService.shared.debug(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n")
        #endif
        #if DEBUG
        advancedUtilitiesTableViewCell.isHidden = false
        #endif
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let canNotificate = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)
        if canNotificate {
            reminderIsOn.text = "On"
        } else {
            reminderIsOn.text = "Off"
        }
    }
    
    //    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    //        guard let footer = view as? UITableViewHeaderFooterView else { return }
    //       // header.textLabel?.textColor = UIColor.red
    //        footer.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    //        //header.textLabel?.frame = header.frame
    //        //header.textLabel?.textAlignment = .center
    //    }
    
    // :???: likely not needed with grouped attribute
    //override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    //    guard let footer = view as? UITableViewHeaderFooterView else { return }
    //    //footer.textLabel?.font = footer.textLabel?.font.withSize(14)
    //    footer.textLabel?.font =  UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.thin)
    //    // :!!!:???: footer.textLabel?.attributedText
    //
    //}
    
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
    
    //    func setDefaults() {
    //        let canNotificate = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)
    //            reminderSwitch.isOn = canNotificate
    //            //settingsPanel.isHidden = !canNotificate
    //
    //            datePicker.date.hour = UserDefaults.standard.integer(forKey: SettingsKeys.reminderHourPref)
    //            datePicker.date.minute = UserDefaults.standard.integer(forKey: SettingsKeys.reminderMinutePref)
    //
    //            soundSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.reminderSoundPref)
    //        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //        guard reminderSwitch.isOn else { return }
        //
        //        UserDefaults.standard.set(soundSwitch.isOn, forKey: SettingsKeys.reminderSoundPref)
        //
        //        if UserDefaults.standard.integer(forKey: SettingsKeys.reminderHourPref) != datePicker.date.hour ||
        //            UserDefaults.standard.integer(forKey: SettingsKeys.reminderMinutePref) != datePicker.date.minute {
        //            UserDefaults.standard.set(datePicker.date.hour, forKey: SettingsKeys.reminderHourPref)
        //            UserDefaults.standard.set(datePicker.date.minute, forKey: SettingsKeys.reminderMinutePref)
        //
        //            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        //
        //            let content = UNMutableNotificationContent()
        //            content.title = Content.title
        //            content.subtitle = Content.subtitle
        //            content.body = Content.body
        //            content.badge = 1
        //
        //            guard
        //                let url = Bundle.main.url(forResource: Content.img, withExtension: Content.png),
        //                let attachment = try? UNNotificationAttachment(identifier: SettingsKeys.imgID, url: url, options: nil)
        //                else { return }
        //
        //            content.attachments.append(attachment)
        //
        //            if soundSwitch.isOn { content.sound = UNNotificationSound.default }
        //
        //            var dateComponents = DateComponents()
        //            dateComponents.hour = UserDefaults.standard.integer(forKey: SettingsKeys.reminderHourPref)
        //            dateComponents.minute = UserDefaults.standard.integer(forKey: SettingsKeys.reminderMinutePref)
        //
        //            let dateTrigget = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        //
        //            let request = UNNotificationRequest(identifier: SettingsKeys.requestID, content: content, trigger: dateTrigget)
        //
        //            UNUserNotificationCenter.current().add(request) { (error) in
        //                if let error = error {
        //                    LogService.shared.error(error.localizedDescription)
        //                }
        //            }
        //        }
    }
    
    //    @IBAction private func reminderSwitched(_ sender: UISwitch) {
    //        //settingsPanel.isHidden = !sender.isOn
    //        UserDefaults.standard.set(sender.isOn, forKey: SettingsKeys.reminderCanNotify)
    //        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    //    }
    
    @IBAction func doTweaksVisibilityChanged(_ sender: UISegmentedControl) {
        //LogService.shared.debug("selectedSegmentIndex = \(segmentedControl.selectedSegmentIndex)")
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
        let viewController = UtilityBuilder.instantiateController()
        navigationController?.pushViewController(viewController, animated: true)
    }
        
}
