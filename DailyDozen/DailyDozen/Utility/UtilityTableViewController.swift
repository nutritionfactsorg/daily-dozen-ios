//
//  UtilityTableViewController.swift
//  DailyDozen
//
//  Created by marc on 2019.11.04.
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

// MARK: - Builder 
class UtilityBuilder {

    // MARK: - Nested
    private struct Strings {
        static let storyboard = "Utility"
    }

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> UIViewController {
        let storyboard = UIStoryboard(name: Strings.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController()
            else { fatalError("Did not instantiate `Utility` controller") }
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
        
        let activityViewController = UIActivityViewController(
            activityItems: [URL.inDocuments(for: backupFilename)],
            applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func doUtilityDBImportDataBtn(_ sender: UIButton) {
    }
    
    @IBAction func doUtilitySettingsClearBtn(_ sender: UIButton) {
        doUtilitySettingsPrint()
        doUtilitySettingsClear()
        doUtilitySettingsPrint()
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
        defaults.set(nil, forKey: SettingsKeys.unitsTypeTogglePref)
        defaults.set(nil, forKey: SettingsKeys.show21TweaksPref)
        defaults.set(nil, forKey: SettingsKeys.hasSeenFirstLaunch)
    }
    
    func doUtilitySettingsPrint() {
        print("\n•• UserDefaults Values ••")
        print("  reminderCanNotify \(UserDefaults.standard.object(forKey: SettingsKeys.reminderCanNotify) ?? "nil")")
        print("   reminderHourPref \(UserDefaults.standard.object(forKey: SettingsKeys.reminderHourPref) ?? "nil")")
        print(" reminderMinutePref \(UserDefaults.standard.object(forKey: SettingsKeys.reminderMinutePref) ?? "nil")")
        print("  reminderSoundPref \(UserDefaults.standard.object(forKey: SettingsKeys.reminderSoundPref) ?? "nil")")
        print("              imgID \(UserDefaults.standard.object(forKey: SettingsKeys.imgID) ?? "nil")")
        print("          requestID \(UserDefaults.standard.object(forKey: SettingsKeys.requestID) ?? "nil")")
        print("      unitsTypePref \(UserDefaults.standard.object(forKey: SettingsKeys.unitsTypePref) ?? "nil")")
        print("unitsTypeTogglePref \(UserDefaults.standard.object(forKey: SettingsKeys.unitsTypeTogglePref) ?? "nil")")
        print("   show21TweaksPref \(UserDefaults.standard.object(forKey: SettingsKeys.show21TweaksPref) ?? "nil")")
        print(" hasSeenFirstLaunch \(UserDefaults.standard.object(forKey: SettingsKeys.hasSeenFirstLaunch) ?? "nil")")
    }
    
    @IBAction func doUtlityTestClearAllDataBtn(_ sender: UIButton) {
        doUtlityTestClearAllData()
    }
    
    func doUtlityTestClearAllData() {
        print("\ndoUtlityTestClearAllData started ...")
        let realmMngrOld = RealmManagerLegacy(workingDirUrl: documentsUrl)
        let realmDbOld = realmMngrOld.realmDb
        realmDbOld.deleteAllLegacy()
        let realmMngrNew = RealmManager(workingDirUrl: documentsUrl)
        let realmDbNew = realmMngrNew.realmDb
        realmDbNew.deleteAll()
        print("... doUtlityTestClearAllData completed\n")
    }
    
    @IBAction func doUtilityTestCreateDataBtn(_ sender: UIButton) {
        doUtilityTestCreateData()
    }
    
    func doUtilityTestCreateData() {
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
        for i in 0..<(365*3) {
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
        print("... doUtilityTestCreateData completed\n")
    }
    
    @IBAction func doUtilityTestCreateLegacyBtn(_ sender: UIButton) {
        doUtilityTestCreateLegacy()
    }
    
    func doUtilityTestCreateLegacy() {
        let realmMngrOldCheck = RealmManagerLegacy(workingDirUrl: documentsUrl)
        let realmDbOldCheck = realmMngrOldCheck.realmDb
        // World Pasta Day: Oct 25, 1995
        let date1995Pasta = Date.init(datestampKey: "19951025")!
        // Add known content to legacy
        let dozeCheck = realmDbOldCheck.getDozeLegacy(for: date1995Pasta)
        realmDbOldCheck.saveStatesLegacy([true, false, true], id: dozeCheck.items[0].id) // Beans
        realmDbOldCheck.saveStatesLegacy([false, true, false], id: dozeCheck.items[2].id) // Other Fruit
    }
    
    @IBAction func doUtilityTestPrintDefaultsBtn(_ sender: UIButton) {
        doUtilitySettingsPrint()
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
