//
//  SettingsReminderView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct SettingsReminderContent {
    static let title = String(localized: "reminder.heading", comment: "Daily Reminder")
    static let body =  String(localized: "reminder.alert.text", comment: "Update your servings today")
    static let img = "dr_greger"
    static let png = "png"
}

//TBDz decide whether to move to main page. Decide style of picker
//TBDz Is there anything that needs to be done with removing notifications? removeDeliveredNotifications(withIdentifiers:)

struct SettingsReminderView: View {
    // @State private var enableReminder = true
    @State private var playNotifySound: Bool = false
    @State private var selectedTime = Date() // Stores the selected
    private let timeKey = "SelectedTime"
    @State private var enableReminder: Bool = false
    
    private func saveTime(_ time: Date) {
        // Only want to save the time part, date is set to an arbitrary day in the past.
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let dateWithOnlyTime = calendar.date(from: components) ?? Date()
        UserDefaults.standard.set(dateWithOnlyTime.timeIntervalSinceReferenceDate, forKey: timeKey)
    }
    
    private func saveCanNotify() {
        UserDefaults.standard.set(enableReminder, forKey: SettingsKeys.reminderCanNotify)
    }
    
    private func saveSoundPref() {
        UserDefaults.standard.set(enableReminder, forKey: SettingsKeys.reminderSoundPref)
    }
    
    private func loadCanNotify() {
        enableReminder = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)
    }
    
    private func loadCanPlaySound() {
        playNotifySound = UserDefaults.standard.bool(forKey: SettingsKeys.reminderSoundPref)
    }
    private func loadTime() {
        if let interval = UserDefaults.standard.object(forKey: timeKey) as? TimeInterval {
            let loadedDate = Date(timeIntervalSinceReferenceDate: interval)
            let calendar = Calendar.current
            let currentDate = Date()
            print("interval: \(interval)")
            // Combine saved time with current date
            let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: loadedDate),
                                             minute: calendar.component(.minute, from: loadedDate),
                                             second: 0,
                                             of: currentDate) ?? Date()
            selectedTime = combinedDate
            setAlarm(for: combinedDate)
        }
    }
    
    private func setAlarm(for date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let newComponents = DateComponents(calendar: calendar, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)  //TBDz check if this is false or true
        let content = UNMutableNotificationContent()
        content.title = SettingsReminderContent.title
        content.body = SettingsReminderContent.body
        if playNotifySound {
            content.sound = .default  //NYIz  need to implement based on preference
        }
        content.badge = 1
        if let url = Bundle.main.url(forResource: "dr_greger", withExtension: "png"),
           let attachment = try? UNNotificationAttachment(identifier: SettingsKeys.reminderRequestID, url: url, options: nil) {
            content.attachments.append(attachment)
        }
        let request = UNNotificationRequest(identifier: SettingsKeys.reminderRequestID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [SettingsKeys.reminderRequestID])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("SettingsReminderViewController viewWillDisappear \(error.localizedDescription)")
            }
        }
    }
    //NYIz based on toggle
    private func cancelAlarm() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [SettingsKeys.reminderRequestID])
    }
    
    // Helper for formatting time in display
    // :TBDz:  May need to move to Date Extension
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    //soundSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.reminderSoundPref)
    //NYIz: grayed out toggled picker instead of just not shown
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                //NYIz need to cancel when toggled off
                if #available(iOS 17.0, *) {
                    Toggle(String(localized: "reminder.settings.enable"), isOn: $enableReminder)
                        .onChange(of: enableReminder) {
                            saveCanNotify()
                            if !enableReminder {
                                cancelAlarm()
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .nfGreenBrand))
                        .padding(10)
                } else {
                    // Fallback on earlier versions
                    
                    Toggle(String(localized: "reminder.settings.enable"), isOn: $enableReminder)
                        .onChange(of: enableReminder) { value in
                            UserDefaults.standard.set(value, forKey: SettingsKeys.reminderCanNotify)
                            if !enableReminder {
                                cancelAlarm()
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .nfGreenBrand))
                        .padding(10)
                }
                if enableReminder {
                    VStack {
                        Text("reminder.settings.time")
                        if #available(iOS 17.0, *) {
                            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()  //needed to center
                                .padding(10)
                            
                                .onChange(of: selectedTime) {
                                    
                                    saveTime(selectedTime)
                                    setAlarm(for: selectedTime)
                                    
                                }
                        } else {
                            // Fallback on earlier versions
                            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()  //needed to center
                                .padding(10)
                                .onChange(of: selectedTime) { timeValue in
                                    
                                    saveTime(timeValue)
                                    setAlarm(for: selectedTime)
                                }
                        }
                       
                        if #available(iOS 17.0, *) {
                            Toggle(String(localized: "reminder.settings.sound"), isOn: $playNotifySound)
                                .onChange(of: playNotifySound) {
                                    saveSoundPref()
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .nfGreenBrand))
                                .padding(10)
                        } else {
                            // Fallback on earlier versions
                            Toggle(String(localized: "reminder.settings.sound"), isOn: $playNotifySound)
                                .onChange(of: playNotifySound) { _ in
                                    saveSoundPref()
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .nfGreenBrand))
                                .padding(10)
                        }
                    }
                }
               
            }
            Spacer()
            //!Notez: Didn't previously have title
              //  .navigationTitle(Text("reminder.settings.enable"))
                .whiteInlineGreenTitle("reminder.settings.enable")

//                .navigationBarTitleDisplayMode(.inline)
//                .toolbarBackground(.visible, for: .navigationBar)
//                .toolbarBackground(.nfGreenBrand, for: .navigationBar)
                .onAppear {
                    loadCanNotify()
                    loadTime()
                    loadCanPlaySound()
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if granted {
                            print("Notification permission granted")
                        } else if let error = error {
                            print("Notification permission denied: \(error.localizedDescription)")
                        }
                    }
                }
            
        }
    }
}

#Preview {
    SettingsReminderView()
}
