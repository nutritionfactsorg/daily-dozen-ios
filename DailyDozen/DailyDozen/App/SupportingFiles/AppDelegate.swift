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
    private struct Strings {
        static let realmExtension = "realm"
        static let realmFilename = "main.realm"
        static let title = "Restore Backup" // :NYI:ToBeLocalized:
        static let message = "Any existing data will be deleted before restoring from backup. Do you wish to continue?" // :NYI:ToBeLocalized:
        static let confirm = "OK" // :NYI:ToBeLocalized:
        static let decline = "NO" // :NYI:ToBeLocalized:
    }
    
    weak var realmDelegate: RealmDelegateLegacy?
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        //print("::::: DEBUG :::::")
        //print(":::::::::::::::::\n")
        #endif
        
        #if targetEnvironment(simulator)
        print("::::: SIMULATOR ENVIRONMENT :::::")
        
        let bundle = Bundle(for: type(of: self))
        print("Bundle & Resources Path:\n\(bundle.bundlePath)\n")

        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            print("App Documents (RealmDB) Directory:\n\(documentsPath)\n")
        }
        
        // Preliminary integrity checks. :NYI: Built-In-Self-Test
        
        if let dozeBeans = DataCountAttributes.shared.dict[.dozeBeans],
            let dozeBerries = DataCountAttributes.shared.dict[.dozeBerries] {
            print("dozeBeans.title = \(dozeBeans.title)")
            print("dozeBerries.title = \(dozeBerries.title)")
        }
        
        print(":::::::::::::::::::::::::::::::::\n")
        #endif
        
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard url.pathExtension == Strings.realmExtension else { return false }
        
        let importAlert = UIAlertController(title: Strings.title,
                                            message: Strings.message,
                                            preferredStyle: .alert)
        let confirm = UIAlertAction(title: Strings.confirm, style: .default) { [weak self] (_) in
            try? FileManager.default.removeItem(at: URL.inDocuments(for: Strings.realmFilename))
            try? FileManager.default.copyItem(at: url, to: URL.inDocuments(for: Strings.realmFilename))
            self?.realmDelegate?.didUpdateFile()
        }
        importAlert.addAction(confirm)
        
        let decline = UIAlertAction(title: Strings.decline, style: .cancel, handler: nil)
        importAlert.addAction(decline)
        
        window?.rootViewController?.show(importAlert, sender: nil)
        return true
    }
}
