//
//  ReminderViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 12.12.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import UserNotifications

// MARK: - Builder
class ReminderBuilder {

    // MARK: - Nested
    private struct Keys {
        static let storyboard = "Reminder"
    }

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> ReminderViewController {
        let storyboard = UIStoryboard(name: Keys.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? ReminderViewController
            else { fatalError("There should be a controller") }
        viewController.title = "Daily Reminder Settings"

        return viewController
    }
}

// MARK: - Controller
class ReminderViewController: UIViewController {

    @IBOutlet private weak var settingsPanel: RoundedView!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var reminderSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        let canNotificate = UserDefaults.standard.bool(forKey: "canNotificate")
        reminderSwitch.isOn = canNotificate
        settingsPanel.isHidden = !canNotificate

        datePicker.date.hour = UserDefaults.standard.integer(forKey: "hour")
        datePicker.date.minute = UserDefaults.standard.integer(forKey: "minute")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard reminderSwitch.isOn else { return }

        if UserDefaults.standard.integer(forKey: "hour") != datePicker.date.hour ||
            UserDefaults.standard.integer(forKey: "minute") != datePicker.date.minute {

            UserDefaults.standard.set(datePicker.date.hour, forKey: "hour")
            UserDefaults.standard.set(datePicker.date.minute, forKey: "minute")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

            let content = UNMutableNotificationContent()
            content.title = "DailyDozen app."
            content.subtitle = "Do you remember about the app?"
            content.body = "Use this app on a daily basis!"
            content.badge = 1
            content.sound = UNNotificationSound.default()

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

    }

    @IBAction private func reminderSwithed(_ sender: UISwitch) {
        settingsPanel.isHidden = !sender.isOn
        UserDefaults.standard.set(sender.isOn, forKey: "canNotificate")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

}
