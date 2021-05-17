//
//  ReminderDetailSettingTableViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

struct SettingsReminderContent {
    static let title = NSLocalizedString("reminder.heading", comment: "Daily Reminder")
    static let body = NSLocalizedString("reminder.alert.text", comment: "Update your servings today")
    static let img = "dr_greger"
    static let png = "png"
}

class SettingsReminderViewController: UITableViewController {
    
    @IBOutlet weak var settingsDatePicker: UIDatePicker!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var soundSwitch: UISwitch!
    //    var soundIsOn: Bool!
    var reminderSwitchPref: Bool!
    //    var time: Date!
    // Labels
    @IBOutlet weak var reminderSwitchLabel: UILabel!
    @IBOutlet weak var remindMeAtLabel: UILabel!
    @IBOutlet weak var soundSwitchLabel: UILabel!
    
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
        reminderSwitchLabel.text = NSLocalizedString("reminder.settings.enable", comment: "Enable Reminders")
        remindMeAtLabel.text = NSLocalizedString("reminder.settings.time", comment: "Remind me at")
        soundSwitchLabel.text = NSLocalizedString("reminder.settings.sound", comment: "Play Sound")
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        reminderSwitch.onTintColor = ColorManager.style.mainMedium
        soundSwitch.onTintColor = ColorManager.style.mainMedium
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Store Settings
        UserDefaults.standard.set(settingsDatePicker.date.hour, forKey: SettingsKeys.reminderHourPref)
        UserDefaults.standard.set(settingsDatePicker.date.minute, forKey: SettingsKeys.reminderMinutePref)
        UserDefaults.standard.set(soundSwitch.isOn, forKey: SettingsKeys.reminderSoundPref)
        // Clear Requests
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        if reminderSwitch.isOn == false {
            return // done
        }
        
        // Notification Content
        let content = UNMutableNotificationContent()
        content.title = SettingsReminderContent.title
        content.body = SettingsReminderContent.body
        content.badge = 1
        if soundSwitch.isOn {
            content.sound = UNNotificationSound.default 
        }
        // NOTE: URL requires an image is outside the assets catalog
        if let url = Bundle.main.url(forResource: SettingsReminderContent.img, withExtension: SettingsReminderContent.png),
           let attachment = try? UNNotificationAttachment(identifier: "", url: url, options: nil) { 
            content.attachments.append(attachment)
        }
        
        // Notification Time Trigger
        var timeComponents = DateComponents()
        timeComponents.hour = settingsDatePicker.date.hour
        timeComponents.minute = settingsDatePicker.date.minute
        let dateTrigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
        
        // Post Notification Request
        let request = UNNotificationRequest(identifier: SettingsKeys.reminderRequestID, content: content, trigger: dateTrigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                LogService.shared.error(
                    "SettingsReminderViewController viewWillDisappear \(error.localizedDescription)"
                )
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
