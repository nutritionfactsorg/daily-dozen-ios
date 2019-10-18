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
    private struct Keys {
        static let extens = "realm"
        static let main = "main.realm"
        static let title = "Restore Backup"
        static let message = "Any existing data will be deleted before restoring from backup. Do you wish to continue?"
        static let confirm = "OK"
        static let decline = "NO"
    }

    weak var realmDelegate: RealmDelegate?

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        // print("::::: DEBUG :::::")
        #endif
        
        #if targetEnvironment(simulator)
            print("::::: SIMULATOR :::::")
            if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
                print("App Documents Directory:\n\(documentsPath)\n")
            }
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
        guard url.pathExtension == Keys.extens else { return false }

        let importAlert = UIAlertController(title: Keys.title,
                                            message: Keys.message,
                                            preferredStyle: .alert)
        let confirm = UIAlertAction(title: Keys.confirm, style: .default) { [weak self] (_) in
            try? FileManager.default.removeItem(at: URL.inDocuments(for: Keys.main))
            try? FileManager.default.copyItem(at: url, to: URL.inDocuments(for: Keys.main))
            self?.realmDelegate?.didUpdateFile()
        }
        importAlert.addAction(confirm)

        let decline = UIAlertAction(title: Keys.decline, style: .cancel, handler: nil)
        importAlert.addAction(decline)

        window?.rootViewController?.show(importAlert, sender: nil)
        return true
    }
}
