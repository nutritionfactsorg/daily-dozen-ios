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
        viewController.title = "Settings"

        return viewController
    }
}

// MARK: - Controller
class ReminderViewController: UIViewController {

    private struct Content {
        static let title = "DailyDozen app."
        static let subtitle = "Do you remember about the app?"
        static let body = "Update your servings for today!"
        static let img = "dr_greger"
        static let png = "png"
    }

    @IBOutlet private weak var settingsPanel: RoundedView!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var reminderSwitch: UISwitch!
    @IBOutlet private weak var soundSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        let canNotificate = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)
        reminderSwitch.isOn = canNotificate
        settingsPanel.isHidden = !canNotificate

        datePicker.date.hour = UserDefaults.standard.integer(forKey: SettingsKeys.reminderHourPref)
        datePicker.date.minute = UserDefaults.standard.integer(forKey: SettingsKeys.reminderMinutePref)

        soundSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.reminderSoundPref)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard reminderSwitch.isOn else { return }

        UserDefaults.standard.set(soundSwitch.isOn, forKey: SettingsKeys.reminderSoundPref)

        if UserDefaults.standard.integer(forKey: SettingsKeys.reminderHourPref) != datePicker.date.hour ||
            UserDefaults.standard.integer(forKey: SettingsKeys.reminderMinutePref) != datePicker.date.minute {
            UserDefaults.standard.set(datePicker.date.hour, forKey: SettingsKeys.reminderHourPref)
            UserDefaults.standard.set(datePicker.date.minute, forKey: SettingsKeys.reminderMinutePref)

            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

            let content = UNMutableNotificationContent()
            content.title = Content.title
            content.subtitle = Content.subtitle
            content.body = Content.body
            content.badge = 1

            guard
                let url = Bundle.main.url(forResource: Content.img, withExtension: Content.png),
                let attachment = try? UNNotificationAttachment(identifier: SettingsKeys.imgID, url: url, options: nil)
                else { return }

            content.attachments.append(attachment)

            if soundSwitch.isOn { content.sound = UNNotificationSound.default }

            var dateComponents = DateComponents()
            dateComponents.hour = UserDefaults.standard.integer(forKey: SettingsKeys.reminderHourPref)
            dateComponents.minute = UserDefaults.standard.integer(forKey: SettingsKeys.reminderMinutePref)

            let dateTrigget = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            let request = UNNotificationRequest(identifier: SettingsKeys.requestID, content: content, trigger: dateTrigget)

            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }

    @IBAction private func reminderSwitched(_ sender: UISwitch) {
        settingsPanel.isHidden = !sender.isOn
        UserDefaults.standard.set(sender.isOn, forKey: SettingsKeys.reminderCanNotify)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

}
