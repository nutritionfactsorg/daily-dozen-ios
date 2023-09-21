//
//  UtilityTableViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

// MARK: - Controller
class UtilityTableViewController: UITableViewController {

    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func newInstance() -> UIViewController {
        let storyboard = UIStoryboard(name: "UtilityLayout", bundle: nil)
        guard
            let viewController = storyboard.instantiateInitialViewController()
            else { fatalError("Did not instantiate `UtilityTableViewController`") }
        viewController.title = "Utility"

        return viewController
    }
    
    // Logger
    let logger = LogService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = ColorManager.style.mainMedium
        navigationController?.navigationBar.tintColor = UIColor.white
        // default height (in points) for each row in the table view
        self.tableView.rowHeight = 42
    }
    
    // MARK: - SQLite Utilities
    
    @IBAction func doUtilitySQLiteClearDbBtn(_ sender: UIButton) {
        SQLiteConnector.run.clearDb()
    }
    
    @IBAction func doUtilitySQLiteCreateDataBtn(_ sender: UIButton) {
        SQLiteConnector.run.createData()
    }
    
    @IBAction func doUtilitySQLiteExportDataBtn(_ sender: UIButton) {
        SQLiteConnector.run.exportData()
    }
    
    @IBAction func doUtilitySQLiteImportDataBtn(_ sender: UIButton) {
        SQLiteConnector.run.importData()
    }
    
    @IBAction func doUtilitySQLiteTimingTextBtn(_ sender: UIButton) {
        SQLiteConnector.run.timingTest()
    }
    
    // MARK: - Realm Utilities
    
    @IBAction func doUtilityRealmClearHistoryBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: Strings.utilityTestHistoryClearMsg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Strings.utilityConfirmCancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        let clearAction = UIAlertAction(title: Strings.utilityConfirmClear, style: .destructive) { (_: UIAlertAction) -> Void in
            RealmBuiltInTest.shared.doClearAllDataInMigrationChainBIT()
        }
        alert.addAction(clearAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// doUtilityTestGenerateHistoryBtn() willl "Generate Test History"
    /// 
    /// Note: When writing a large number of data entries AND 
    /// the database is open in the Realm browser is open, 
    /// then some value(s) may not be written.  
    /// Do not have the Realm browser open when writing data in simulator to
    /// avoid this is situation. The root cause of this issue is unknown.
    @IBAction func doUtilityRealmGenerateHistoryBtn(_ sender: UIButton) {
        // half month
        //RealmBuiltInTest.shared.doGenerateDBHistoryBIT(numberOfDays: 15, defaultDB: true)
        
        // :SQLITE:TBD: three years -> 1095 days
        RealmBuiltInTest.shared.doGenerateDBHistoryBIT(numberOfDays: 1095, defaultDB: true)
    }
    
    /// doUtilityRealmGenerateStreaksBtn(…) "Simulate Progress"
    @IBAction func doUtilityRealmGenerateStreaksBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: Strings.utilityTestStreaksMsg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Strings.utilityConfirmCancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        let generateAction = UIAlertAction(title: Strings.utilityConfirmOK, style: .destructive) { (_: UIAlertAction) -> Void in
            let busyAlert = AlertActivityBar()
            busyAlert.setText("Generating Progress Data") // :NYI:LOCALIZE:
            busyAlert.show()
            DispatchQueue.global(qos: .userInitiated).async {
                // lower priority job here
                RealmBuiltInTest.shared.doGenerateDBStreaksBIT(activityProgress: busyAlert)
                DispatchQueue.main.async {
                    // update ui here
                    busyAlert.completed()
                }
            }
        }
        alert.addAction(generateAction)
                
        UIApplication.shared.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func doUtilityRealmDBExportBtn(_ sender: UIButton) {
        doUtilityRealmDBExport()
    }
    
    private func doUtilityRealmDBExport() {
        logger.info("UtilityTableViewController doUtilityRealmDBExport()")
        let realmMngr = RealmManager(newThread: true)
        let backupFilename = realmMngr.csvExport(marker: "db_export_data")
        // :SQLITE:TBD: export debug scope
        #if DEBUG_NOT
        _ = realmMngr.csvExportWeight(marker: "db_export_weight")
        HealthSynchronizer.shared.syncWeightExport(marker: "hk_export_weight")
        #endif
        
        let str = "\(Strings.utilityDbExportMsg): \"\(backupFilename)\"."
        
        let alert = UIAlertController(title: "", message: str, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.utilityConfirmOK, style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func doUtilityRealmDBImportBtn(_ sender: UIButton) {
        //ImportPopupPickerView.show(
        //    items: [String],
        //    doneButtonCompletion: ImportPopupPickerView.CompletionBlock?,
        //    didSelectCompletion: ImportPopupPickerView.CompletionBlock?,
        //    cancelButtonCompletion: ImportPopupPickerView.CompletionBlock?
        //)
        
        //ImportPopupPickerView.show(
        //    items: ["item1", "item2", "item3"],
        //    itemIds: ["id1", "id2", "id3"],
        //    selectedValue: "item3", 
        //    doneButtonCompletion: { (item: String?, index: String?) in
        //        LogService.shared.debug("done", item ?? "nil", index ?? "nil")}, 
        //    didSelectCompletion: { (item: String?, index: String?) in
        //        LogService.shared.debug("selection", item ?? "nil", index ?? "nil") },
        //    cancelButtonCompletion: { (item: String?, index: String?) in
        //        LogService.shared.debug("cancelled", item ?? "nil", index ?? "nil") }
        //)
    }
    
    // MARK: - Date & Time Utilities
    
    @IBAction func doUtilityRealmAddOneDayBtn(_ sender: UIButton) {
        DateManager.incrementDay()
    }
    
    // MARK: - Appearance
    
    // Appearance Type: Standard | Preview
    @IBOutlet weak var appearanceTypeControl: UISegmentedControl!
    
    @IBAction func doAppearanceTypeChanged(_ sender: UISegmentedControl) {
        logger.info(":NYI: doAppearanceModeChanged not implemented")
    }
    
    // MARK: - Settings
    
    @IBAction func doUtilitySettingsClearBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: Strings.utilitySettingsClearMsg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Strings.utilityConfirmCancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        let clearAction = UIAlertAction(title: Strings.utilityConfirmClear, style: .destructive) { (_: UIAlertAction) -> Void in
            self.doUtilitySettingsClear()
        }
        alert.addAction(clearAction)
        present(alert, animated: true, completion: nil)
    }
    
    func doUtilitySettingsClear() {
        let defaults = UserDefaults.standard
        /// Reminder
        defaults.set(nil, forKey: SettingsKeys.reminderCanNotify)
        defaults.set(nil, forKey: SettingsKeys.reminderHourPref)
        defaults.set(nil, forKey: SettingsKeys.reminderMinutePref)
        defaults.set(nil, forKey: SettingsKeys.reminderSoundPref)
        /// Units Type: imperial|metric
        defaults.set(nil, forKey: SettingsKeys.unitsTypePref)
        /// unitsTypeToggleShowPref: shows units type toggle button when true|"1"|"on"
        defaults.set(nil, forKey: SettingsKeys.unitsTypeToggleShowPref)
        /// Hide|Show 21 Tweaks
        defaults.set(nil, forKey: SettingsKeys.show21TweaksPref)
        /// Used for first launch
        defaults.set(nil, forKey: SettingsKeys.hasSeenFirstLaunch)
        
        // Analytics is enabled when when true|"1"|"on"
        defaults.set(nil, forKey: SettingsKeys.analyticsIsEnabledPref)
        
        // Light | Dark | Auto
        defaults.set(nil, forKey: SettingsKeys.appearanceModePref)
        // Standard | Preview
        defaults.set(nil, forKey: SettingsKeys.appearanceTypePref)
    }
    
    @IBAction func doUtilitySettingsShowBtn(_ sender: UIButton) {
        doUtilitySettingsShow()
    }
    
    func doUtilitySettingsShow() {
        var str = ""

        str.append(contentsOf: "reminderCanNotify: ")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.reminderCanNotify) ?? "nil")\n")

        str.append(contentsOf: "reminderHourPref")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.reminderHourPref) ?? "nil")\n")

        str.append(contentsOf: "reminderMinutePref")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.reminderMinutePref) ?? "nil")\n")

        str.append(contentsOf: "reminderSoundPref")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.reminderSoundPref) ?? "nil")\n")

        str.append(contentsOf: "unitsTypePref")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.unitsTypePref) ?? "nil")\n")

        str.append(contentsOf: "unitsTypeToggleShowPref")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.unitsTypeToggleShowPref) ?? "nil")\n")

        str.append(contentsOf: "show21TweaksPref")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.show21TweaksPref) ?? "nil")\n")
        
        str.append(contentsOf: "hasSeenFirstLaunch")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.hasSeenFirstLaunch) ?? "nil")\n")
        
        str.append(contentsOf: "analyticsIsEnabledPref")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.analyticsIsEnabledPref) ?? "nil")\n")
        
        str.append(contentsOf: "appearanceModePref")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.appearanceModePref) ?? "nil")\n")
        
        str.append(contentsOf: "appearanceTypePref")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.appearanceTypePref) ?? "nil")\n")
        
        #if DEBUG
        LogService.shared.debug(
            """
            UtilityTableViewController doUtilitySettingsShow()…\n
            ••• UserDefaults Values •••\n
            \(str)
            """
        )
        #endif
        
        let alert = UIAlertController(title: "", message: str, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.utilityConfirmOK, style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - **Private**
    
    private struct Strings { // :NYI:LOCALIZE: localize utility strings
        static let utilityConfirmCancel = "Cancel"
        static let utilityConfirmClear = "Clear"
        static let utilityConfirmOK = "OK"
        static let utilityDbExportMsg = "Exported file named "
        static let utilitySettingsClearMsg = "Clear (erase) all settings?\n\nThis cannot be undone."
        static let utilityTestHistoryClearMsg = "Export the history data to create an importable backup file before clearing the history data. The clear action cannot be undone.\n\nClear (erase) all history data from the database?"
        static let utilityTestStreaksMsg = "The Simulate Progress action cannot be undone. If needed, export the history data to create an importable backup file.\n\nAdd the Simulated Progress data to the database?"
    }
    
    private func alertTwoButton() {
        let alertController = UIAlertController(title: "Default Style", message: "A standard alert.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) -> Void in
            LogService.shared.debug(
                "••CANCEL•• UtilityTableViewController alertTwoButton() \(action)"
            )
        }
        alertController.addAction(cancelAction)

        let okAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) -> Void in
            LogService.shared.debug(
                "••OK•• UtilityTableViewController alertTwoButton() \(action)"
            )
        }
        alertController.addAction(okAction)

        let destroyAction = UIAlertAction(title: "Destroy", style: .destructive) { (action: UIAlertAction) -> Void in
            LogService.shared.debug(
                "••DESTROY•• UtilityTableViewController alertTwoButton() \(action)"
            )
        }
        alertController.addAction(destroyAction)
        
        self.present(alertController, animated: true, completion: nil) // (() -> Void)?
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    //}

}
