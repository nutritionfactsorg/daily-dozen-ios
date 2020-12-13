//
//  ReminderDetailSettingTableViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

class SettingsReminderViewController: UITableViewController {
    
    private struct Content {
        static let title = "DailyDozen app."
        static let subtitle = "Do you remember about the app?"
        static let body = "Update your servings for today!"
        static let img = "dr_greger"
        static let png = "png"
    }
    @IBOutlet weak var settingsDatePicker: UIDatePicker!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var soundSwitch: UISwitch!
    //    var soundIsOn: Bool!
    var reminderSwitchPref: Bool!
    //    var time: Date!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
            settingsDatePicker.datePickerMode = .time
            settingsDatePicker.date.hour = UserDefaults.standard.integer(forKey: SettingsKeys.reminderHourPref)
            settingsDatePicker.date.minute = UserDefaults.standard.integer(forKey: SettingsKeys.reminderMinutePref)
            
        let canNotificate = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)
        reminderSwitch.isOn = canNotificate
        if reminderSwitch.isOn {
            soundSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.reminderSoundPref)
        } else {
            settingsDatePicker.isEnabled = false
            soundSwitch.isEnabled = false
        }
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard reminderSwitch.isOn else { return }
        
        UserDefaults.standard.set(soundSwitch.isOn, forKey: SettingsKeys.reminderSoundPref)
        
        if UserDefaults.standard.integer(forKey: SettingsKeys.reminderHourPref) != settingsDatePicker.date.hour ||
            UserDefaults.standard.integer(forKey: SettingsKeys.reminderMinutePref) != settingsDatePicker.date.minute {
            UserDefaults.standard.set(settingsDatePicker.date.hour, forKey: SettingsKeys.reminderHourPref)
            UserDefaults.standard.set(settingsDatePicker.date.minute, forKey: SettingsKeys.reminderMinutePref)
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            // Alert content
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
            
            let dateTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            // post notification request
            let request = UNNotificationRequest(identifier: SettingsKeys.requestID, content: content, trigger: dateTrigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    LogService.shared.error(
                        "SettingsReminderViewController viewWillDisappear \(error.localizedDescription)"
                    )
                }
            }
        }
    }
    
    @IBAction func reminderSwitched(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: SettingsKeys.reminderCanNotify)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        if reminderSwitch.isOn {
            settingsDatePicker.isEnabled = true
            soundSwitch.isEnabled = true
        } else {
            settingsDatePicker.isEnabled = false
            soundSwitch.isEnabled = false
        }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.destination is SettingsViewController {
    //           LogService.shared.debug("leaving detail")
    //           LogService.shared.debug(UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify))
    //            }
    //        }
}
