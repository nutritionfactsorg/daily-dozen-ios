//
//  AppDelegate.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Nested
    //private struct Strings {
    //    static let realmExtension = "realm"
    //    static let realmFilename = "main.realm"
    //    static let title = "Restore Backup" // :NYI:ToBeLocalized:
    //    static let message = "Any existing data will be deleted before restoring from backup. Do you wish to continue?" // :NYI:ToBeLocalized:
    //    static let confirm = "OK" // :NYI:ToBeLocalized:
    //    static let decline = "NO" // :NYI:ToBeLocalized:
    //}
    
    weak var realmDelegate: RealmDelegate?
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let fm = FileManager.default
        let urlList = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsUrl = urlList[0]
        
        #if DEBUG
        //print("::::: DEBUG :::::")
        //print(":::::::::::::::::\n")
        #endif
        
        #if targetEnvironment(simulator)
        print("::::: SIMULATOR ENVIRONMENT :::::")
        let bundle = Bundle(for: type(of: self))
        print("Bundle & Resources Path:\n\(bundle.bundlePath)\n")
        let documentsPath = documentsUrl.path
        print("App Documents (RealmDB) Directory:\n\(documentsPath)\n")
        
        /*
        // Preliminary integrity checks.
        let realmMngrOldCheck = RealmManagerLegacy(workingDirUrl: documentsUrl)
        let realmDbOldCheck = realmMngrOldCheck.realmDb
        // World Pasta Day: Oct 25, 1995
        let date1995Pasta = Date.init(datestampKey: "19951025")!
        // Add known content to legacy
        let dozeCheck = realmDbOldCheck.getDozeLegacy(for: date1995Pasta)
        realmDbOldCheck.saveStatesLegacy([true, false, true], id: dozeCheck.items[0].id) // Beans
        realmDbOldCheck.saveStatesLegacy([false, true, false], id: dozeCheck.items[2].id) // Other Fruits
        */
 
        print(":::::::::::::::::::::::::::::::::\n")
        #endif
        
        // Update legacy database if not already updated
        if !UserDefaults.standard.bool(forKey: "didUpdateLegacyDatabase") {
            let realmMngrOld = RealmManagerLegacy(workingDirUrl: documentsUrl)
            let legacyExportFilename = realmMngrOld.csvExport()
            
            let realmMngrNew = RealmManager(workingDirUrl: documentsUrl)
            realmMngrNew.csvImport(filename: legacyExportFilename)
            UserDefaults.standard.set(true, forKey: "didUpdateLegacyDatabase")
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (_, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    //func application(_ app: UIApplication,
    //                 open url: URL,
    //                 options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    //    guard url.pathExtension == Strings.realmExtension else { return false }
    //
    //    let importAlert = UIAlertController(title: Strings.title,
    //                                        message: Strings.message,
    //                                        preferredStyle: .alert)
    //    let confirm = UIAlertAction(title: Strings.confirm, style: .default) { [weak self] (_) in
    //        try? FileManager.default.removeItem(at: URL.inDocuments(for: Strings.realmFilename))
    //        try? FileManager.default.copyItem(at: url, to: URL.inDocuments(for: Strings.realmFilename))
    //        self?.realmDelegate?.didUpdateFile()
    //    }
    //    importAlert.addAction(confirm)
    //
    //    let decline = UIAlertAction(title: Strings.decline, style: .cancel, handler: nil)
    //    importAlert.addAction(decline)
    //
    //    window?.rootViewController?.show(importAlert, sender: nil)
    //    return true
    //}
}
