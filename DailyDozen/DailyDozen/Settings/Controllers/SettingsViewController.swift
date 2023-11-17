//
//  SettingsViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable type_body_length
// swiftlint:disable file_length
// swiftlint:disable function_body_length

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
    @IBOutlet weak var historyDataExportBtn: UIButton!
    @IBOutlet weak var historyDataImportBtn: UIButton!
    
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
        
        // History Data
        historyDataExportBtn.setTitle(
            NSLocalizedString("history_data_export_btn", comment: "Export"),
            for: .normal)
        historyDataImportBtn.setTitle(
            NSLocalizedString("history_data_import_btn", comment: "Import"),
            for: .normal)
        historyDataExportBtn.setTitleColor(ColorManager.style.mainMedium, for: UIControl.State.normal)
        historyDataImportBtn.setTitleColor(ColorManager.style.mainMedium, for: UIControl.State.normal)
        
        // Analytics
        analyticsEnableLabel.text = NSLocalizedString("setting_analytics_enable", comment: "Enable Analytics")
        
        #if targetEnvironment(simulator)
        logit.debug("::::: SIMULATOR ENVIRONMENT: SettingsViewController :::::")
        advancedUtilitiesTableViewCell.isHidden = false // :ADVANCED:DEBUG:
        //advancedUtilitiesTableViewCell.isHidden = true // :ADVANCED:RELEASE:
        print("ADVANCED UTILITIES advancedUtilitiesTableViewCell.isHidden == \(advancedUtilitiesTableViewCell.isHidden)")
        logit.debug(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n")
        #endif
        #if DEBUG
        advancedUtilitiesTableViewCell.isHidden = false // :ADVANCED:#DEBUG:
        //advancedUtilitiesTableViewCell.isHidden = true // :ADVANCED:#RELEASE:
        print("ADVANCED UTILITIES advancedUtilitiesTableViewCell.isHidden == \(advancedUtilitiesTableViewCell.isHidden)")
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
        else { return }
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
        let alertMsgBodyStr = NSLocalizedString("setting_analytics_body", comment: "Analytics request")
        let alertMsgTitleStr = NSLocalizedString("setting_analytics_title", comment: "Analytics title")
        let optInStr = NSLocalizedString("setting_analytics_opt_in", comment: "Opt-In")
        let optOutStr = NSLocalizedString("setting_analytics_opt_out", comment: "Opt-Out")

        let alert = UIAlertController(title: alertMsgTitleStr, message: alertMsgBodyStr, preferredStyle: .alert)
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
        logit.info("SettingsViewController doAnalyticsEnable() completed")
    }
    
    func doAnalyticsDisable() {
        if FirebaseApp.app() != nil {
            Analytics.setAnalyticsCollectionEnabled(false)
            logit.info("SettingsViewController doAnalyticsDisable() disabled existing FirebaseApp Analytics")
        }
        UserDefaults.standard.set(false, forKey: SettingsKeys.analyticsIsEnabledPref)
        analyticsEnableToggle.isOn = false
        logit.info("SettingsViewController doAnalyticsDisable() completed")
    }
    
    //@IBAction func doAppearanceModeChanged(_ sender: UISegmentedControl) {
    //    print(":TBD: doAppearanceModeChanged not implemented")
    //}
    
    var backupFilename: String?
    
    @IBAction func doHistoryDataExport(_ sender: UIButton) {
        //doHistoryDataExportActivityNone()
        doHistoryDataExportActivityShow()
    }
    
    func doHistoryDataExportActivityNone() {
        logit.info("SettingsViewController doHistoryDataExportActivityNone()")
        let realmMngr = RealmManager()
        backupFilename = realmMngr.csvExport(marker: "DailyDozen")
        // :SQLITE:TBD: export debug scope
        #if DEBUG_NOT
        _ = realmMngr.csvExportWeight(marker: "weight_db_dev")
        HealthSynchronizer.shared.syncWeightExport(marker: "weight_hk_dev")
        #endif
        
        //doHistoryDataExportAlert()
        doHistoryDataExportShare()
    }
    
    func doHistoryDataExportActivityShow() {
        logit.info("SettingsViewController doHistoryDataExportActivityShow()")
        
        // -----------------
        let busyAlert = AlertActivityBar()
        let msg = NSLocalizedString("history_data_export_btn", comment: "Export")
        busyAlert.setText(msg)
        busyAlert.show()
        DispatchQueue.global(qos: .userInitiated).async {
            // lower priority job here
            let realmMngr = RealmManager(newThread: true)
            
            self.backupFilename = realmMngr.csvExport(marker: "DailyDozen", activity: busyAlert)
            // :SQLITE:TBD: export debug scope
            #if DEBUG_NOT
            _ = realmMngr.csvExportWeight(marker: "weight_db_dev")
            HealthSynchronizer.shared.syncWeightExport(marker: "weight_hk_dev")
            #endif
            DispatchQueue.main.async {
                // update ui here
                busyAlert.completed()
                //doHistoryDataExportAlert()
                self.doHistoryDataExportShare()
            }
        }
    }
    
    func doHistoryDataExportAlert() {
        guard let backupFilename else { return }
        logit.info("SettingsViewController ... doHistoryDataExportAlert")
        let msg = NSLocalizedString("history_data_export_text", comment: "Export has been written to: ")
        let strMsg = "\(msg)\n\n\(backupFilename)"
        
        let strOK = NSLocalizedString("history_data_alert_ok", comment: "OK")
        let alert = UIAlertController(title: "", message: strMsg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: strOK, style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)        
    }
    
    func doHistoryDataExportShare() {
        guard let backupFilename else { return }
        logit.info("SettingsViewController ... doHistoryDataExportShare")
        // --- Presents share services for AirDrop, Files, etc ---
        let urls: [URL] = [URL.inDocuments(filename: backupFilename)]
        let activityVC = UIActivityViewController(
            activityItems: urls,  // provided file path url
            applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = {
            (activity: UIActivity.ActivityType?, completed: Bool, items: [Any]?, error: Error?) in
            
            let errorStr = error?.localizedDescription ?? "none"
            
            logit.debug(
            """
            doHistoryDataExportShare() completionWithItemsHandler
                activity: \(String(describing: activity))
                items: \(String(describing: items))
                completed: \(completed)
                error: \(errorStr)\n
            """)
        }
        
        var excludedActivityTypes: [UIActivity.ActivityType] = [
            .addToReadingList,
            //.airDrop,
            .assignToContact,
            //.copyToPasteboard,
            //.mail,
            .markupAsPDF,
            //.message,
            .openInIBooks,
            .postToFlickr,
            .postToTencentWeibo,
            .postToTwitter,
            .postToVimeo,
            .postToWeibo,
            .print,
            .saveToCameraRoll,
            UIActivity.ActivityType(rawValue: "com.amazon.Lassen.SendToKindleExtension"),
            UIActivity.ActivityType(rawValue: "com.apple.reminders.sharingextension"),
            UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),
            UIActivity.ActivityType(rawValue: "com.google.chrome.ios.ShareExtension"),
        ]
        if #available(iOS 15.4, *) {
            excludedActivityTypes.append(.sharePlay)
        }
        if #available(iOS 16.0, *) {
            excludedActivityTypes.append(.collaborationInviteWithLink)
            excludedActivityTypes.append(.collaborationCopyLink)
        }
        if #available(iOS 16.4, *) {
            excludedActivityTypes.append(.addToHomeScreen)
        }
        activityVC.excludedActivityTypes = excludedActivityTypes
        
        var subject = NSLocalizedString("CFBundleDisplayName", 
                                        tableName: "InfoPlist",
                                        comment: "DailyDozen")
        subject.append(" \(Date.datestampExportSubject())")
        activityVC.setValue(subject, forKey: "Subject")
        
        activityVC.popoverPresentationController?.sourceRect = self.view.frame
        //activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func doHistoryDataImport(_ sender: UIButton) {
        logit.info("SettingsViewController doHistoryDataImport()")
        
        // Get qualified files
        let fileUrls = doHistoryDataImportFileFind()
                
        if fileUrls.isEmpty {
            doHistoryDataImportFileNotFoundAlert()
            return
        }
        
        var filenameList: [String] = []
        var filenameIndices: [String] = []
        for idx in 0 ..< fileUrls.count {
            filenameList.append(fileUrls[idx].lastPathComponent)
            filenameIndices.append("\(idx)")
        }
        
        ImportPopupPickerView.show(
            cancelTitle: NSLocalizedString("history_data_alert_cancel", comment: "Cancel"), 
            doneTitle: NSLocalizedString("history_data_alert_import", comment: "Import"),
            items: filenameList, 
            itemIds: filenameIndices
            //selectedValue: String?
        ) { 
            // importButtonCompletion
            (item: String?, id: String?) in
            logit.debug("importButtonCompletion item:\(item ?? "nil") id:\(id ?? "nil")")
            if let id = id, let idx = Int(id) {
                let csvUrl = fileUrls[idx]
                self.doHistoryDataImportFile(csvUrl: csvUrl)
            }
        } didSelectCompletion: { 
            // didSelectCompletion is called each time scroll selection changes
            (_: String?, _: String?) in
            // Nothing to do.
        } cancelButtonCompletion: { (_: String?, _: String?) in
            // Nothing to do.
        }
    }
    
    func doHistoryDataImportFileFind() -> [URL] {
        var csvFileList: [URL] = []
        let fm = FileManager.default
        
        do {
            // Get the document directory url
            let docDirUrl = try fm.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            logit.debug("docDirUrl: \(docDirUrl.path)")
            
            // Get the directory contents urls (including subfolders urls)
            let docDirContents = try fm.contentsOfDirectory(
                at: docDirUrl,
                includingPropertiesForKeys: nil
            )
            logit.debug("docDirContents: \(docDirContents)")
            
            guard let csvHeaderCheck = "Date,Beans,Berries,".data(using: .utf8, allowLossyConversion: false) else {
                logit.debug("doHistoryDataImportFileFind did not create csvHeaderCheck")
                return csvFileList 
            }
            let byteCount = csvHeaderCheck.count
            
            for url in docDirContents {
                if url.pathExtension.lowercased() == "csv" {
                    let handle = try FileHandle(forReadingFrom: url)
                    if #available(iOS 13.4, *) {
                        if let firstBytes = try handle.read(upToCount: byteCount) {
                            if firstBytes == csvHeaderCheck {
                                csvFileList.append(url)
                            }
                        }
                        try handle.close()
                    } else {
                        // Fallback on earlier versions
                        // :DEPRECATED:
                        let firstBytes: Data = handle.readData(ofLength: byteCount)
                        if firstBytes == csvHeaderCheck {
                            csvFileList.append(url)
                        }
                        handle.closeFile()
                    }
                }
            }
        } catch {
            logit.debug("doHistoryDataImportFileFind() \(error)")
        }
        
        return csvFileList.sorted {
            $0.lastPathComponent < $1.lastPathComponent
        }
    }
    
    func doHistoryDataImportFile(csvUrl: URL) {
        doHistoryDataImportFileConfirmAlert(csvUrl: csvUrl)
    }
    
    func doHistoryDataImportFileNotFoundAlert() {
        let alertMsgTitleStr = NSLocalizedString("history_data_title", comment: "History")
        let alertMsgBodyStr = NSLocalizedString("history_data_import_notfound_text", comment: "file not found")
        let okStr = NSLocalizedString("history_data_alert_ok", comment: "Ok")

        let alert = UIAlertController(title: alertMsgTitleStr, message: alertMsgBodyStr, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okStr, style: .default) {
            (_: UIAlertAction) -> Void in
            // nothing to do
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func doHistoryDataImportFileConfirmAlert(csvUrl: URL) {
        let alertMsgTitleStr = NSLocalizedString("history_data_title", comment: "History")
        let alertMsgBodyStr = NSLocalizedString("history_data_import_caution_text", comment: "caution: will overwrite")
        let importStr = NSLocalizedString("history_data_alert_import", comment: "Import")
        let cancelStr = NSLocalizedString("history_data_alert_cancel", comment: "Cancel")
        
        let alert = UIAlertController(title: alertMsgTitleStr, message: alertMsgBodyStr, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelStr, style: .default) {
            (_: UIAlertAction) -> Void in
            // nothing to do
        }
        alert.addAction(cancelAction)
        
        let importAction = UIAlertAction(title: importStr, style: .default) {
            (_: UIAlertAction) -> Void in
            self.doDataHistoryImportHandler(csvUrl: csvUrl)
        }
        alert.addAction(importAction)
        present(alert, animated: true, completion: nil)
    }
    
    func doDataHistoryImportHandler(csvUrl: URL) {
        // import to NutritionFacts.realm
        let realmUrl = URL.inDatabase(filename: RealmProvider.realmFilenameScratch)
        let realmManager = RealmManager(fileURL: realmUrl)
        
        realmManager.csvImport(url: csvUrl) 
        // :GTD: check/verify for successful Settings import
        
        let fm = FileManager.default
        do {
            // • Backup primary database
            try fm.moveItem(
                at: URL.inDatabase(filename: RealmProvider.realmFilename), 
                to: URL.inDatabase(filename: RealmProvider.realmFilenameNowstamp())
            )
            
            // • Move imported database into primary database location
            try fm.moveItem(
                at: URL.inDatabase(filename: RealmProvider.realmFilenameScratch), 
                to: URL.inDatabase(filename: RealmProvider.realmFilename)
            )
            
            // • Insure connection to the new current "primary" database
            RealmProvider.initialize(
                fileURL: URL.inDatabase(filename: RealmProvider.realmFilename))
            
            // • Cleanup. Remove excess backups.
            let backupList = RealmProvider.realmBackupList()
            let backupMaxCount = 5 // excess threshold
            if backupList.count > backupMaxCount {
                let excessList = backupList.prefix(backupList.count - backupMaxCount)
                for filename in excessList {
                    try fm.removeItem(at: URL.inDatabase(filename: filename))
                }
            }
        } catch {
            // csvUrl.path() 'path(percentEncoded:)' requires iOS 16.0 or newer
            // csvUrl.path will be deprecated in a future version of iOS
            logit.error("""
                doDataHistoryImportHandler
                    csvfile:\(csvUrl.path)
                    error:'\(error)'
                """)
        }
    }
    
    @IBAction func doTweaksVisibilityChanged(_ sender: UISegmentedControl) {
        // logit.debug("selectedSegmentIndex = \(segmentedControl.selectedSegmentIndex)")
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
        case 3: // Database Export/Import: "History"
            sectionName = NSLocalizedString("history_data_title", comment: "History")
        case 4: // Firebase Analytics: "Analytics"
            sectionName = NSLocalizedString("setting_analytics_title", comment: "Analytics")
        case 5: // Advanced Utilities: no header
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
        case 3: // Database Export/Import: no footer
            sectionName = ""
        case 4: // Firebase Analytics: no footer
            sectionName = ""
        case 5: // Advanced Utilities: no footer
            sectionName = ""
        default:
            sectionName = ""
        }
        return sectionName
    }
    
}
