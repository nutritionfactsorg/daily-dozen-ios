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

        if UserDefaults.standard.object(forKey: "canNotificate") == nil {

            UNUserNotificationCenter.current().getNotificationSettings { settings in
                UserDefaults.standard.set(settings.authorizationStatus == .authorized, forKey: "canNotificate")
            }
        }

        if UserDefaults.standard.object(forKey: "hour") == nil {
            UserDefaults.standard.set(8, forKey: "hour")
        }

        if UserDefaults.standard.object(forKey: "minute") == nil {
            UserDefaults.standard.set(0, forKey: "minute")
        }

        if UserDefaults.standard.object(forKey: "sound") == nil {
            UserDefaults.standard.set(true, forKey: "sound")
        }

        guard UserDefaults.standard.bool(forKey: "canNotificate") else { return }

        let content = UNMutableNotificationContent()
        content.title = "DailyDozen app."
        content.subtitle = "Do you remember about the app?"
        content.body = "Use this app on a daily basis!"
        content.badge = 1

        if UserDefaults.standard.bool(forKey: "sound") {
            content.sound = UNNotificationSound.default()
        }

        var dateComponents = DateComponents()
        dateComponents.hour = UserDefaults.standard.integer(forKey: "hour")
        dateComponents.minute = UserDefaults.standard.integer(forKey: "minute")

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
