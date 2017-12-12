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

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (_, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }

        let action = UNNotificationAction(identifier: "action", title: "REMINDER!", options: [.foreground])

        let category = UNNotificationCategory(
            identifier: "category", actions: [action],
            intentIdentifiers: [], options: [])

        UNUserNotificationCenter.current().setNotificationCategories([category])

        return true
    }
}
