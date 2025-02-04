//
//  SettingsReminderView.swift
//  DailyDozen
//
//  Created by mc on 1/22/25.
//

import SwiftUI

struct SettingsReminderView: View {
    @State private var enableReminder = true
    @State private var playSound = false
    @State private var selectedTime = Date() // Stores the selected
    private let timeKey = "SelectedTime"
    let canNotificate = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)
   
    private func saveTime(_ time: Date) {
           // We only want to save the time part, so we set the date to an arbitrary day in the past.
           let calendar = Calendar.current
           let components = calendar.dateComponents([.hour, .minute], from: time)
           let dateWithOnlyTime = calendar.date(from: components) ?? Date()
           UserDefaults.standard.set(dateWithOnlyTime.timeIntervalSinceReferenceDate, forKey: timeKey)
       }
    private func loadTime() {
            if let interval = UserDefaults.standard.object(forKey: timeKey) as? TimeInterval {
                let loadedDate = Date(timeIntervalSinceReferenceDate: interval)
                let calendar = Calendar.current
                let currentDate = Date()
                
                // Combine saved time with current date
                let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: loadedDate),
                                                 minute: calendar.component(.minute, from: loadedDate),
                                                 second: 0,
                                                 of: currentDate) ?? Date()
                selectedTime = combinedDate
            }
        }
        
        // Helper for formatting time in display
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
                Toggle(String(localized: "reminder.settings.enable"), isOn: $enableReminder)
                    .toggleStyle(SwitchToggleStyle(tint: .brandGreen))
                    .padding(10)
                if enableReminder {
                    VStack {
                        DatePicker("reminder.settings.time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .padding(10)
                            
                            .onChange(of: selectedTime) {
                                newValue in
                                saveTime(newValue)
                            }
                        //TBD For debug only, remove in production
                        Text("Selected Time: \(selectedTime, formatter: timeFormatter)")
                        Toggle(String(localized: "reminder.settings.sound"), isOn: $playSound)
                            .toggleStyle(SwitchToggleStyle(tint: .brandGreen))
                            .padding(10)
                    }
                }
            }
            Spacer()
            //!Notez: Didn't previously have title
         .navigationTitle(Text("reminder.settings.enable"))
         .navigationBarTitleDisplayMode(.inline)
         .toolbarBackground(.visible, for: .navigationBar)
         .toolbarBackground(.brandGreen, for: .navigationBar)
         .onAppear {
             
             loadTime()
             
         }
        
        }
    }
}

#Preview {
        SettingsReminderView()
}
