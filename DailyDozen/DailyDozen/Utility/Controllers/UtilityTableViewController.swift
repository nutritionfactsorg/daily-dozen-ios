//
//  UtilityTableViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

// MARK: - Builder 
class UtilityBuilder {

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> UIViewController {
        let storyboard = UIStoryboard(name: "UtilityLayout", bundle: nil)
        guard
            let viewController = storyboard.instantiateInitialViewController()
            else { fatalError("Did not instantiate `UtilityTableViewController`") }
        viewController.title = "Utility"

        return viewController
    }
}

// MARK: - Controller
class UtilityTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white

    }

    // MARK: - Table view data source

    // Simple static storyboard table
    
    // MARK: - Actions
    
    private var documentsUrl: URL {
        let fm = FileManager.default
        let urlList = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsUrl = urlList[0]
        return documentsUrl
    }
        
    @IBAction func doUtilityDBExportDataBtn(_ sender: UIButton) {
        doUtilityDBExportData()
    }
    
    /// Presents share services.
    private func doUtilityDBExportData() { // see also presentShareServices() { // Backup
        let fm = FileManager.default
        let urlList = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsUrl = urlList[0]
        let realmMngr = RealmManager(workingDirUrl: documentsUrl)
        let backupFilename = realmMngr.csvExport()
        
        let str = "\(Strings.utilityDbExportMsg): \"\(backupFilename)\"."
        
        let alert = UIAlertController(title: "", message: str, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: Strings.utilityConfirmOK, style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
        //let activityViewController = UIActivityViewController(
        //    activityItems: [URL.inDocuments(for: backupFilename)],
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
        //        print("done", item ?? "nil", index ?? "nil")}, 
        //    didSelectCompletion: { (item: String?, index: String?) in
        //        print("selection", item ?? "nil", index ?? "nil") },
        //    cancelBottonCompletion: { (item: String?, index: String?) in
        //        print("cancelled", item ?? "nil", index ?? "nil") }
        //)
    }
    
    @IBAction func doUtilitySettingsClearBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: Strings.utilitySettingsClearMsg, preferredStyle: .actionSheet)
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
        defaults.set(nil, forKey: SettingsKeys.imgID)
        defaults.set(nil, forKey: SettingsKeys.requestID)
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

        //str.append(contentsOf: "imgID")
        //str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.imgID) ?? "nil")\n")

        //str.append(contentsOf: "requestID")
        //str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.requestID) ?? "nil")\n")

        str.append(contentsOf: "unitsTypePref")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.unitsTypePref) ?? "nil")\n")

        str.append(contentsOf: "unitsTypeToggleShowPref")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.unitsTypeToggleShowPref) ?? "nil")\n")

        str.append(contentsOf: "show21TweaksPref")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.show21TweaksPref) ?? "nil")\n")
        
        str.append(contentsOf: "hasSeenFirstLaunch")
        str.append(contentsOf: ": \(UserDefaults.standard.object(forKey: SettingsKeys.hasSeenFirstLaunch) ?? "nil")\n")
        
        #if DEBUG
        print("\n•• UserDefaults Values ••")
        print(str)
        #endif
        
        let alert = UIAlertController(title: "", message: str, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: Strings.utilityConfirmOK, style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func doUtilityTestClearHistoryBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: Strings.utilityTestHistoryClearMsg, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: Strings.utilityConfirmCancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        let clearAction = UIAlertAction(title: Strings.utilityConfirmClear, style: .destructive) { (_: UIAlertAction) -> Void in
            self.doUtilityTestClearHistory()
        }
        alert.addAction(clearAction)
        present(alert, animated: true, completion: nil)
    }
    
    func doUtilityTestClearHistory() {
        print("\ndoUtlityTestClearAllData started ...")
        let realmMngrOld = RealmManagerLegacy(workingDirUrl: documentsUrl)
        let realmDbOld = realmMngrOld.realmDb
        realmDbOld.deleteAllLegacy()
        let realmMngrNew = RealmManager(workingDirUrl: documentsUrl)
        let realmDbNew = realmMngrNew.realmDb
        realmDbNew.deleteAll()
        print("... doUtilityTestClearHistory completed\n")
    }
    
    /// Note: When writing a large number of data entries AND the database is open 
    /// in the Realm browser is open, then some value(s) may not be written.  
    /// Do not have the Realm browser open when writing data in simulator to
    /// avoid this is situation. The root cause of this issue is unknown.
    @IBAction func doUtilityTestGenerateHistoryBtn(_ sender: UIButton) {
        // half month
        doUtilityTestGenerateHistory(numberOfDays: 15)
        
        // ~1 month
        //doUtilityTestGenerateHistory(numberOfDays: 30)
        
        // ~10 months
        //doUtilityTestGenerateHistory(numberOfDays: 300)

        // ~2.7 years or ~33 months (1000 days, 2000 weight entries)
        //doUtilityTestGenerateHistory(numberOfDays: 1000)
        
        // 3 years (1095 days, 2190 weight entries)
        //doUtilityTestGenerateHistory(numberOfDays: 365*3)
    }
    
    func doUtilityTestGenerateHistory(numberOfDays: Int) {
        print("\ndoUtilityTestCreateData started ...")
        let realmMngrCheck = RealmManager(workingDirUrl: documentsUrl)
        let realmDbCheck = realmMngrCheck.realmDb
        
        let calendar = Calendar.current
        let today = Date() // today

        let dateComponents = DateComponents(
            calendar: calendar,
            year: today.year, month: today.month, day: today.day,
            hour: 0, minute: 0, second: 0
            )
        var date = calendar.date(from: dateComponents)!
        
        let weightBase = 65.0 // kg
        print("baseWeigh \(weightBase) kg, \(weightBase * 2.2) lbs")
        let weightAmplitude = 2.0 // kg
        let weightCycleStep = (2 * Double.pi) / (30 * 2)
        for i in 0..<numberOfDays { 
            let stepByDay = DateComponents(day: -1)
            date = calendar.date(byAdding: stepByDay, to: date)!

            // Add data counts
            realmDbCheck.saveCount(3, date: date, countType: .dozeBeans) // 0-3
            realmDbCheck.saveCount(Int.random(in: 0...3), date: date, countType: .dozeFruitsOther) // 0-3

            let stepByAm = DateComponents(
                hour: Int.random(in: 7...8),
                minute: Int.random(in: 1...59)
            )
            let dateAm = calendar.date(byAdding: stepByAm, to: date)!

            let stepByPm = DateComponents(
                hour: Int.random(in: 21...23),
                minute: Int.random(in: 1...59)
            )
            let datePm = calendar.date(byAdding: stepByPm, to: date)!
            
            //
            let x = Double(i)
            let weightAm = weightBase + weightAmplitude * sin(x * weightCycleStep)
            let weightPm = weightBase - weightAmplitude * sin(x * weightCycleStep)

            realmDbCheck.saveWeight(date: dateAm, weightType: .am, kg: weightAm)
            realmDbCheck.saveWeight(date: datePm, weightType: .pm, kg: weightPm)
            
            if i < 5 {
                let weightAmStr = String(format: "%.2f", weightAm)
                let weightPmStr = String(format: "%.2f", weightAm)
                print("\(date) [AM] \(dateAm) \(weightAmStr) [PM] \(datePm) \(weightPmStr)")
            }
        }
        print("... doUtilityTestGenerateHistory completed\n")
    }
    
    @IBAction func doUtilityTestGenerateLegacyBtn(_ sender: UIButton) {
        doUtilityTestGenerateLegacy()
    }
    
    func doUtilityTestGenerateLegacy() {
        let realmMngrOldCheck = RealmManagerLegacy(workingDirUrl: documentsUrl)
        let realmDbOldCheck = realmMngrOldCheck.realmDb
        // World Pasta Day: Oct 25, 1995
        let date1995Pasta = Date.init(datestampKey: "19951025")!
        // Add known content to legacy
        let dozeCheck = realmDbOldCheck.getDozeLegacy(for: date1995Pasta)
        realmDbOldCheck.saveStatesLegacy([true, false, true], id: dozeCheck.items[0].id) // Beans
        realmDbOldCheck.saveStatesLegacy([false, true, false], id: dozeCheck.items[2].id) // Other Fruit
    }

    // MARK: - UI
    
    private struct Strings { // :NYI:LOCALIZE: localize utility strings
        static let utilityConfirmCancel = "Cancel"
        static let utilityConfirmClear = "Clear"
        static let utilityConfirmOK = "OK"
        static let utilityDbExportMsg = "Exported file named "
        static let utilitySettingsClearMsg = "Clear (erase) all settings?\n\nThis cannot be undone."
        static let utilityTestHistoryClearMsg = "Export the history data to create an importable backup file before clearing the history data. The clear action cannot be undone.\n\nClear (erase) all history data from the database?"
    }
        
    private func alertTwoButton() {
        let alertController = UIAlertController(title: "Default Style", message: "A standard alert.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) -> Void in
            print(":DEBUG: \(action)")            
        }
        alertController.addAction(cancelAction)

        let okAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) -> Void in
            print(":DEBUG: \(action)")            
        }
        alertController.addAction(okAction)

        let destroyAction = UIAlertAction(title: "Destroy", style: .destructive) { (action: UIAlertAction) -> Void in
            print(":DEBUG: \(action)")            
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

}
