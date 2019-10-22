//
//  MainViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import UserNotifications

class MainViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        if UserDefaults.standard.object(forKey: SettingsKeys.unitsTypePref) == nil {
            // :NYI:ToBeLocalized: set initial default based on device language
            UserDefaults.standard.set(UnitsType.imperial.rawValue, forKey: SettingsKeys.unitsTypePref)
        }
        
        if UserDefaults.standard.object(forKey: SettingsKeys.reminderCanNotify) == nil {

            UNUserNotificationCenter.current().getNotificationSettings { settings in
                UserDefaults.standard.set(settings.authorizationStatus == .authorized, forKey: SettingsKeys.reminderCanNotify)
            }
        }

        if UserDefaults.standard.object(forKey: SettingsKeys.reminderHourPref) == nil {
            UserDefaults.standard.set(8, forKey: SettingsKeys.reminderHourPref)
        }

        if UserDefaults.standard.object(forKey: SettingsKeys.reminderMinutePref) == nil {
            UserDefaults.standard.set(0, forKey: SettingsKeys.reminderMinutePref)
        }

        if UserDefaults.standard.object(forKey: SettingsKeys.reminderSoundPref) == nil {
            UserDefaults.standard.set(true, forKey: SettingsKeys.reminderSoundPref)
        }

        guard UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify) else { return }

        let content = UNMutableNotificationContent()
        content.title = "DailyDozen app." // :NYI:ToBeLocalized:
        content.subtitle = "Do you remember about the app?" // :NYI:ToBeLocalized:
        content.body = "Use this app on a daily basis!" // :NYI:ToBeLocalized:
        content.badge = 1

        if UserDefaults.standard.bool(forKey: SettingsKeys.reminderSoundPref) {
            content.sound = UNNotificationSound.default
        }

        var dateComponents = DateComponents()
        dateComponents.hour = UserDefaults.standard.integer(forKey: SettingsKeys.reminderHourPref)
        dateComponents.minute = UserDefaults.standard.integer(forKey: SettingsKeys.reminderMinutePref)

        let dateTrigget = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "request", content: content, trigger: dateTrigget)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

extension MainViewController: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {

        completionHandler()
    }
}
