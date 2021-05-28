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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = ColorManager.style.mainMedium
        navigationController?.navigationBar.tintColor = UIColor.white
        // default height (in points) for each row in the table view
        self.tableView.rowHeight = 42
    }

    // MARK: - Table view data source

    // Simple static storyboard table
    
    // MARK: - Actions
        
    @IBAction func doUtilityDBExportDataBtn(_ sender: UIButton) {
        doUtilityDBExportData()
    }
    
    /// Presents share services.
    private func doUtilityDBExportData() { // see also presentShareServices() { // Backup
        let realmMngr = RealmManager()
        let backupFilename = realmMngr.csvExport(marker: "db_export_data")
        #if DEBUG
        _ = realmMngr.csvExportWeight(marker: "db_export_weight")
        HealthSynchronizer.shared.syncWeightExport(marker: "hk_export_weight")
        #endif
        
        let str = "\(Strings.utilityDbExportMsg): \"\(backupFilename)\"."
        
        let alert = UIAlertController(title: "", message: str, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.utilityConfirmOK, style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
        //let activityViewController = UIActivityViewController(
        //    activityItems: [URL.inDocuments(filename: backupFilename)],
        //    applicationActivities: nil)
        //activityViewController.popoverPresentationController?.sourceView = view
        //present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func doUtilityDBImportDataBtn(_ sender: UIButton) {
        //PopupPickerView.show(
        //    items: <#T##[String]#>, 
        //    doneBottonCompletion: <#T##PopupPickerView.CompletionBlock?##PopupPickerView.CompletionBlock?##(String?, String?) -> Void#>, 
        //    didSelectCompletion: <#T##PopupPickerView.CompletionBlock?##PopupPickerView.CompletionBlock?##(String?, String?) -> Void#>, 
        //    cancelBottonCompletion: <#T##PopupPickerView.CompletionBlock?##PopupPickerView.CompletionBlock?##(String?, String?) -> Void#>
        //)
        
        //PopupPickerView.show(
        //    items: ["item1", "item2", "item3"],
        //    itemIds: ["id1", "id2", "id3"],
        //    selectedValue: "item3", 
        //    doneBottonCompletion: { (item: String?, index: String?) in
        //        LogService.shared.debug("done", item ?? "nil", index ?? "nil")}, 
        //    didSelectCompletion: { (item: String?, index: String?) in
        //        LogService.shared.debug("selection", item ?? "nil", index ?? "nil") },
        //    cancelBottonCompletion: { (item: String?, index: String?) in
        //        LogService.shared.debug("cancelled", item ?? "nil", index ?? "nil") }
        //)
    }
    
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
        defaults.set(nil, forKey: SettingsKeys.reminderCanNotify)
        defaults.set(nil, forKey: SettingsKeys.reminderHourPref)
        defaults.set(nil, forKey: SettingsKeys.reminderMinutePref)
        defaults.set(nil, forKey: SettingsKeys.reminderSoundPref)
        defaults.set(nil, forKey: SettingsKeys.unitsTypePref)
        defaults.set(nil, forKey: SettingsKeys.unitsTypeToggleShowPref)
        defaults.set(nil, forKey: SettingsKeys.show21TweaksPref)
        defaults.set(nil, forKey: SettingsKeys.hasSeenFirstLaunch)
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
    
    // MARK: - Test Database
    
    @IBAction func doUtilityTestClearHistoryBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: Strings.utilityTestHistoryClearMsg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Strings.utilityConfirmCancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        let clearAction = UIAlertAction(title: Strings.utilityConfirmClear, style: .destructive) { (_: UIAlertAction) -> Void in
            //self.doUtilityTestClearHistoryMigrationsChain()
            DatabaseBuiltInTest.shared.doClearAllDataInMigrationChainBIT()
        }
        alert.addAction(clearAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// Note: When writing a large number of data entries AND the database is open 
    /// in the Realm browser is open, then some value(s) may not be written.  
    /// Do not have the Realm browser open when writing data in simulator to
    /// avoid this is situation. The root cause of this issue is unknown.
    @IBAction func doUtilityTestGenerateHistoryBtn(_ sender: UIButton) {
        // half month
        DatabaseBuiltInTest.shared.doGenerateDBHistoryBIT(numberOfDays: 15, defaultDB: true)
    }
    
    @IBAction func doUtilityTestGenerateLegacyBtn(_ sender: UIButton) {
        DatabaseBuiltInTest.shared.doGenerateDBLegacyDataBIT()
    }
    
    /// "Simulate Progress"
    @IBAction func doUtilityTestGenerateStreaksBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: Strings.utilityTestStreaksMsg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Strings.utilityConfirmCancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        let generateAction = UIAlertAction(title: Strings.utilityConfirmOK, style: .destructive) { (_: UIAlertAction) -> Void in
            let busyAlert = AlertActivityBar()
            busyAlert.setText("Generating Progress Data") // :NYI:LOCALIZE:
            busyAlert.show()
            DispatchQueue.global(qos: .userInitiated).async {
                // lower priority job here
                DatabaseBuiltInTest.shared.doGenerateDBStreaksBIT(activityProgress: busyAlert)
                DispatchQueue.main.async {
                    // update ui here
                    busyAlert.completed()
                }
            }
        }
        alert.addAction(generateAction)
                
        UIApplication.shared.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UI
    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func doUtilityTestAddOneDayBtn(_ sender: UIButton) {
        DateManager.incrementDay()
    }
    
}
