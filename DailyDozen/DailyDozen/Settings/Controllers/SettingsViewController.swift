//
//  SettingsViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit
import UserNotifications
// Analytics Frameworks
import Firebase
import FirebaseAnalytics // "Google Analytics"

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
    @IBOutlet weak var tweakVisibilityControl: UISegmentedControl!
    // Appearance Mode: Light | Dark | Auto
    //@IBOutlet weak var appearanceModeControl: UISegmentedControl!
    // History Data
    //@IBOutlet weak var historyDataExportBtn: UIButton!
    //@IBOutlet weak var historyDataImportBtn: UIButton!
    // Analytics: OFF | ON
    @IBOutlet weak var analyticsEnableLabel: UILabel!
    @IBOutlet weak var analyticsEnableToggle: UISwitch!
    
    // Advance Utilities
    @IBOutlet weak var advancedUtilitiesTableViewCell: UITableViewCell! // .isHidden
    
    enum UnitsSegmentState: Int {
        case imperialState = 0
        case metricState = 1
        case toggleUnitsState = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = ColorManager.style.mainMedium
        navigationController?.navigationBar.tintColor = UIColor.white
        // default height (in points) for each row in the table view
        self.tableView.rowHeight = 42
        
        // Measurement Units
        unitMeasureToggle.tintColor = ColorManager.style.mainMedium
        unitMeasureToggle.setTitle(
            NSLocalizedString("setting_units_0_imperial", comment: "Imperial"), 
            forSegmentAt: 0)
        unitMeasureToggle.setTitle(
            NSLocalizedString("setting_units_1_metric", comment: "Metric"),
            forSegmentAt: 1)
        unitMeasureToggle.setTitle(
            NSLocalizedString("setting_units_2_toggle", comment: "Toggle Units"), 
            forSegmentAt: 2)
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
        tweakVisibilityControl.tintColor = ColorManager.style.mainMedium
        tweakVisibilityControl.setTitle(
            NSLocalizedString("setting_doze_only_choice", comment: "Daily Dozen Only"), 
            forSegmentAt: 0)
        tweakVisibilityControl.setTitle(
            NSLocalizedString("setting_doze_tweak_choice", comment: "Daily Dozen + 21 Tweaks"),
            forSegmentAt: 1)
        if UserDefaults.standard.bool(forKey: SettingsKeys.show21TweaksPref) {
            tweakVisibilityControl.selectedSegmentIndex = 1
        } else {
            tweakVisibilityControl.selectedSegmentIndex = 0
        }
        
        // Appearance Mode
        //appearanceModeControl.tintColor = ColorManager.style.mainMedium
        //appearanceModeControl.setTitle(
        //    NSLocalizedString("setting_appearance_mode_light", comment: "Light"),
        //    forSegmentAt: 0)
        //appearanceModeControl.setTitle(
        //    NSLocalizedString("setting_appearance_mode_dark", comment: "Dark"),
        //    forSegmentAt: 1)
        //appearanceModeControl.setTitle(
        //    NSLocalizedString("setting_appearance_mode_auto", comment: "Auto"),
        //    forSegmentAt: 2)
        
        // Appearance Mode
        setUnitsMeasureSegment()
        
        // History Data
        //historyDataExportBtn.setTitle(
        //    NSLocalizedString("history_data_export_btn", comment: "Export"),
        //    for: .normal)
        //historyDataImportBtn.setTitle(
        //    NSLocalizedString("history_data_import_btn", comment: "Import"),
        //    for: .normal)
        
        // Analytics
        analyticsEnableLabel.text = NSLocalizedString("setting_analytics_enable", comment: "Enable Analytics")
        
        #if targetEnvironment(simulator)
        LogService.shared.debug("::::: SIMULATOR ENVIRONMENT: SettingsViewController :::::")
        advancedUtilitiesTableViewCell.isHidden = false
        //advancedUtilitiesTableViewCell.isHidden = true // :UI_TEST:
        print("ADVANCED UTILITIES advancedUtilitiesTableViewCell.isHidden == \(advancedUtilitiesTableViewCell.isHidden)")
        LogService.shared.debug(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n")
        #endif
        #if DEBUG
        advancedUtilitiesTableViewCell.isHidden = false
        print("ADVANCED UTILITIES advancedUtilitiesTableViewCell.isHidden == \(advancedUtilitiesTableViewCell.isHidden)")
        //advancedUtilitiesTableViewCell.isHidden = true // :UI_TEST:
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
        
        analyticsEnableToggle.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.analyticsIsEnabledPref)
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
    
    @IBAction func doUnitsTypePrefChanged(_ sender: UISegmentedControl) {
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
    
    // MARK: - Actions
    
    @IBAction func doAnalyticsSwitched(_ sender: UISwitch) {
        // Set UserDefaults to the latest (current) user choice
        UserDefaults.standard.set(sender.isOn, forKey: SettingsKeys.analyticsIsEnabledPref)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        if analyticsEnableToggle.isOn { // isOn value after user selection
            doAnalyticsConsent()
        } else {
            doAnalyticsDisable()
        }
    }
    
    func doAnalyticsConsent() {
        let alertMsgBogyStr = NSLocalizedString("setting_analytics_body", comment: "Analytics request")
        let alertMsgTitleStr = NSLocalizedString("setting_analytics_title", comment: "Analytics title")
        let optInStr = NSLocalizedString("setting_analytics_opt_in", comment: "Opt-In")
        let optOutStr = NSLocalizedString("setting_analytics_opt_out", comment: "Opt-Out")

        let alert = UIAlertController(title: alertMsgTitleStr, message: alertMsgBogyStr, preferredStyle: .alert)
        let optOutAction = UIAlertAction(title: optOutStr, style: .default) {
            (_: UIAlertAction) -> Void in
            self.doAnalyticsDisable()
        }
        alert.addAction(optOutAction)
        let optInAction = UIAlertAction(title: optInStr, style: .default) {
            (_: UIAlertAction) -> Void in
            self.doAnalyticsEnable()
        }
        alert.addAction(optInAction)
        present(alert, animated: true, completion: nil)
    }
    
    func doAnalyticsEnable() {
        //if FirebaseApp.app() == nil {
        //    FirebaseApp.configure()
        //}
        Analytics.setAnalyticsCollectionEnabled(true)
        UserDefaults.standard.set(true, forKey: SettingsKeys.analyticsIsEnabledPref)
        analyticsEnableToggle.isOn = true
        LogService.shared.info("SettingsViewController doAnalyticsEnable() completed")
    }
    
    func doAnalyticsDisable() {
        if FirebaseApp.app() != nil {
            Analytics.setAnalyticsCollectionEnabled(false)
            LogService.shared.info("SettingsViewController doAnalyticsDisable() disabled existing FirebaseApp Analytics")
        }
        UserDefaults.standard.set(false, forKey: SettingsKeys.analyticsIsEnabledPref)
        analyticsEnableToggle.isOn = false
        LogService.shared.info("SettingsViewController doAnalyticsDisable() completed")
    }
    
    //@IBAction func doAppearanceModeChanged(_ sender: UISegmentedControl) {
    //    print(":!!!: doAppearanceModeChanged not implemented")
    //}
    //
    //@IBAction func doHistoryDataExport(_ sender: UIButton) {
    //    print(":!!!: doHistoryDataExport not implemented")
    //}
    //
    //@IBAction func doHistoryDataImport(_ sender: UIButton) {
    //    print(":!!!: doHistoryDataImport not implemented")
    //}
    
    @IBAction func doTweaksVisibilityChanged(_ sender: UISegmentedControl) {
        // LogService.shared.debug("selectedSegmentIndex = \(segmentedControl.selectedSegmentIndex)")
        let show21Tweaks = UserDefaults.standard.bool(forKey: SettingsKeys.show21TweaksPref)
        if tweakVisibilityControl.selectedSegmentIndex == 0
            && show21Tweaks {
            // Toggle to hide 2nd tab
            UserDefaults.standard.set(false, forKey: SettingsKeys.show21TweaksPref)
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "NoticeUpdatedShowTweaksTab"),
                object: 2, // Dozen, More, Settings
                userInfo: nil)
        } else if tweakVisibilityControl.selectedSegmentIndex == 1
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
     // MARK: - Storyboard Navigation
     
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
            sectionName = NSLocalizedString("setting_units_header", comment: "Measurement Units")
        case 1: // GiY-ao-2ee.headerTitle
            sectionName = NSLocalizedString("reminder.heading", comment: "Daily Reminder")
        case 2: // WdR-XV-IyP.headerTitle
            sectionName = NSLocalizedString("setting_tweak_header", comment: "21 Tweaks Visibility")
        case 3: // Firebase Analytics: no header
            sectionName = NSLocalizedString("setting_analytics_title", comment: "Analytics")
        case 4: // Advanced Utilities: no header
            sectionName = ""
        default:
            sectionName = ""
        }
        return sectionName
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionName: String
        switch section {
        case 0: // Measurement Units
            sectionName = NSLocalizedString("setting_units_choice_footer", comment: "Measurement Units Footer")
        case 1: // Reminder: no footer
            sectionName = ""
        case 2: // 21 Tweaks Visibility
            sectionName = NSLocalizedString("setting_doze_tweak_footer", comment: "21 Tweaks Visibility Footer")
        case 3: // Firebase Analytics: no footer
            sectionName = ""
        case 4: // Advanced Utilities: no footer
            sectionName = ""
        default:
            sectionName = ""
        }
        return sectionName
    }
    
}
