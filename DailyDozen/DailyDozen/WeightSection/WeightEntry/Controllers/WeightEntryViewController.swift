//
//  WeightEntryViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable file_length
// swiftlint:disable function_body_length

import UIKit
import HealthKit

class WeightEntryViewController: UIViewController {
    
    // MARK: - Outlets
    
    // Labels
    @IBOutlet weak var labelMorning: UILabel!
    @IBOutlet weak var labelEvening: UILabel!
    @IBOutlet weak var labelAmTime: UILabel!
    @IBOutlet weak var labelPmTime: UILabel!
    
    // Text Edit
    @IBOutlet weak var timeAMEntry: UITextField!
    @IBOutlet weak var timePMEntry: UITextField!
    @IBOutlet weak var weightAMEntry: UITextField!
    @IBOutlet weak var weightPMEntry: UITextField!
    
    @IBOutlet weak var weightAMLabel: UILabel!
    @IBOutlet weak var weightPMLabel: UILabel!
    
    // Buttons
    @IBOutlet weak var clearWeightAMButton: UIButton!
    @IBOutlet weak var clearWeightPMButton: UIButton!
    
    // MARK: - Properties
    private let realm = RealmProvider()
    public var currentViewDateWeightEntry: Date = DateManager.currentDatetime() {
        didSet {
            LogService.shared.debug("@DATE \(currentViewDateWeightEntry.datestampKey) WeightEntryViewController")
        }
    }
    private var timePickerAM: UIDatePicker!
    private var timePickerPM: UIDatePicker!
    
    var pidAM: String {
        return "\(currentViewDateWeightEntry.datestampKey).am"
    }
    
    var pidPM: String {
        return "\(currentViewDateWeightEntry.datestampKey).pm"
    }
    
    var pidWeight: String {
        return "\(currentViewDateWeightEntry.datestampKey).tweakWeightTwice"
    }
    
    // MARK: - Data Actions
    
    func clearIBWeight(ampm: DataWeightType) {
        if ampm == .am {
            timeAMEntry.text = ""
            weightAMEntry.text = ""
        } else {
            timePMEntry.text = ""
            weightPMEntry.text = ""
        }
        HealthSynchronizer.shared.syncWeightClear(date: currentViewDateWeightEntry, ampm: ampm)
        updateWeightDataCount()
    }
    
    /// Save weight values from InterfaceBuilder (IB) fields
    /// :TBD:???:ToBeLocalized: `time*Entry.text` need to be local independent for synced put record
    func saveIBWeight(ampm: DataWeightType) {
        let datestampKey = currentViewDateWeightEntry.datestampKey
        LogService.shared.debug(
            "•HK• WeightEntryViewController saveIBWeight \(datestampKey)"
        )
        
        if
            let timeText = ampm == .am ? timeAMEntry.text : timePMEntry.text,
            let weightText = ampm == .am ? weightAMEntry.text : weightPMEntry.text,
            let date = Date(healthkit: "\(datestampKey) \(timeText)"),
            let normalizedWeight = UnitsUtility.normalizedKgWeight(
                from: weightText,
                fromUnits: SettingsManager.unitsType()
            )
        {
            HealthSynchronizer.shared.syncWeightPut(date: date, ampm: ampm, kg: normalizedWeight)
        }
        // Update local counter
        updateWeightDataCount()
    }
        
    /// showIBWeight() when "BodyMassDataAvailable" notification occurs
    @objc func showIBWeight(notification: Notification) {
        LogService.shared.debug("•HK• WeightEntryViewController showIBWeight")
        guard let healthRecord = notification.object as? HealthWeightRecord else {
            return
        }
        
        let weightToShow = healthRecord.getIBWeightToShow()
        if healthRecord.ampm == .am {
            timeAMEntry.text = weightToShow.time
            weightAMEntry.text = weightToShow.weight
        } else {
            timePMEntry.text = weightToShow.time
            weightPMEntry.text = weightToShow.weight
        }
    }
    
    /// Notification: "NoticeChangedUnitsType"
    @objc func changedUnitsType(notification: Notification) {
        guard let isImperial = notification.object as? Bool else {
            return
        }
        
        // Unit Type
        if isImperial {
            weightAMLabel.text = NSLocalizedString("weight_entry_units_lbs", comment: "imperial system pounds")
            weightPMLabel.text = NSLocalizedString("weight_entry_units_lbs", comment: "imperial system pounds")
            if let txt = weightAMEntry.text {
                weightAMEntry.text = UnitsUtility.convertKgToLbs(txt)
            }
            if let txt = weightPMEntry.text {
                weightPMEntry.text = UnitsUtility.convertKgToLbs(txt)
            }
        } else {
            weightAMLabel.text = NSLocalizedString("weight_entry_units_kg", comment: "metric system kilograms")
            weightPMLabel.text = NSLocalizedString("weight_entry_units_kg", comment: "metric system kilograms")
            if let txt = weightAMEntry.text {
                weightAMEntry.text = UnitsUtility.convertLbsToKg(txt)
            }
            if let txt = weightPMEntry.text {
                weightPMEntry.text = UnitsUtility.convertLbsToKg(txt)
            }
        }
    }
    
    // MARK: - UI Actions
    @IBAction func clearWeightAMButtonPressed(_ sender: Any) {
        // :NYI: confirm clear & delete
        view.endEditing(true)
        clearIBWeight(ampm: .am)
    }
    
    @IBAction func clearWeightPMButtonPressed(_ sender: Any) {
        // :NYI: confirm clear & delete
        view.endEditing(true)
        clearIBWeight(ampm: .pm)
    }
    
    /// Update "weight twice daily" tweak tracker 
    /// for current date view using database values
    private func updateWeightDataCount() {
        let recordAM = realm.getDBWeight(date: currentViewDateWeightEntry, ampm: .am)
        let recordPM = realm.getDBWeight(date: currentViewDateWeightEntry, ampm: .pm)
        var count = 0
        if recordAM != nil {
            count += 1
        }
        if recordPM != nil {
            count += 1
        }
        
        realm.saveCount(count, date: currentViewDateWeightEntry, countType: .tweakWeightTwice)
    }
    
    // Note: call once upon entry from tweaks checklist or history
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelMorning.text = NSLocalizedString("weight_entry_morning", comment: "Morning")
        labelEvening.text = NSLocalizedString("weight_entry_evening", comment: "Evening")

        let timeStr = NSLocalizedString("weight_entry_time", comment: "Time")
        labelAmTime.text = timeStr
        labelPmTime.text = timeStr

        let clearStr = NSLocalizedString("weight_entry_clear", comment: "Clear")
        clearWeightAMButton.setTitle(clearStr, for: .normal)
        clearWeightPMButton.setTitle(clearStr, for: .normal)
        
        weightPMEntry.delegate = self
        weightAMEntry.delegate = self
        timeAMEntry.delegate = self
        timePMEntry.delegate = self
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.realmDelegate = self
        
        // AM Morning
        timePickerAM = UIDatePicker() // :TBD:???: add min-max contraints?
        timePickerAM.datePickerMode = .time
        if #available(iOS 13.4, *) {
            // Expressly use inline wheel (UIPickerView) style.
            timePickerAM.preferredDatePickerStyle = .wheels
            timePickerAM.sizeToFit()
        }
        timePickerAM.addTarget(self, action: #selector(WeightEntryViewController.timeChangedAM(timePicker:)), for: .valueChanged)
        timeAMEntry.inputView = timePickerAM // assign initial value
        
        // PM Evening
        timePickerPM = UIDatePicker() // :TBD:???: add min-max contraints?
        timePickerPM.datePickerMode = .time
        if #available(iOS 13.4, *) {
            // Expressly use inline wheel (UIPickerView) style.
            timePickerPM.preferredDatePickerStyle = .wheels
            timePickerPM.sizeToFit()
        }        
        timePickerPM.addTarget(self, action: #selector(WeightEntryViewController.timeChangedPM(timePicker:)), for: .valueChanged)
        timePMEntry.inputView = timePickerPM
        
        setViewModel(date: currentViewDateWeightEntry)
        
        // Unit Type
        if SettingsManager.isImperial() {
            weightAMLabel.text = NSLocalizedString("weight_entry_units_lbs", comment: "imperial system pounds")
            weightPMLabel.text = NSLocalizedString("weight_entry_units_lbs", comment: "imperial system pounds")
        } else {
            weightAMLabel.text = NSLocalizedString("weight_entry_units_kg", comment: "metric system kilograms")
            weightPMLabel.text = NSLocalizedString("weight_entry_units_kg", comment: "metric system kilograms")
        }
        
        //
        let tapGesture = UITapGestureRecognizer(
            target: self, 
            action: #selector(WeightEntryViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(changedUnitsType(notification:)),
            name: Notification.Name(rawValue: "NoticeChangedUnitsType"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showIBWeight(notification:)),
            name: Notification.Name(rawValue: "BodyMassDataAvailable"),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        LogService.shared.debug("WeightEntryViewController viewWillAppear")
        super.viewWillAppear(animated)
        setViewModel(date: self.currentViewDateWeightEntry)
    }
    
    /// Return to previous screen. Not invoked by date pager.
    override func viewWillDisappear(_ animated: Bool) {
        LogService.shared.debug("WeightEntryViewController viewWillDisappear")
        super.viewWillDisappear(animated)
        // Update stored values
        saveIBWeight(ampm: .am)
        saveIBWeight(ampm: .pm)
    }
    
    func getTimeNow() -> String {
        let dateNow = DateManager.currentDatetime()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        // dateFormatter.setLocalizedDateFormatFromTemplate(<#T##dateFormatTemplate: String##String#>) :TBD:ToBeLocalized?
        let timeNow = dateFormatter.string(from: dateNow)
        return timeNow
    }
    
    // MARK: - Methods
    /// Sets a view model for the current date.
    ///
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    ///
    @objc func timeChangedAM(timePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        let min = dateFormatter.date(from: "12:00")      //creating min time
        let max = dateFormatter.date(from: "11:59")
        dateFormatter.dateFormat = "hh:mm a"
        // dateFormatter.setLocalizedDateFormatFromTemplate(<#T##dateFormatTemplate: String##String#>) :TBD:ToBeLocalized?
        timePicker.minimumDate = min
        timePicker.maximumDate = max
        timeAMEntry.text = dateFormatter.string(from: timePicker.date)
        //view.endEditing(true)
    }
    
    @objc func timeChangedPM(timePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        let min = dateFormatter.date(from: "12:00")      //creating min time
        let max = dateFormatter.date(from: "11:59")
        dateFormatter.dateFormat = "hh:mm a"
        // dateFormatter.setLocalizedDateFormatFromTemplate(<#T##dateFormatTemplate: String##String#>) :TBD:ToBeLocalized?
        timePicker.minimumDate = min
        timePicker.maximumDate = max
        timePMEntry.text = dateFormatter.string(from: timePicker.date)
        //view.endEditing(true)
    }
    
    /// Set the current date.
    ///
    /// Note: updated by pager.
    ///
    /// - Parameter item: sets the current date.
    func setViewModel(date: Date) {
        LogService.shared.debug("•HK• WeightEntryViewController setViewModel \(date.datestampKey)")
        // Update or create stored values from the current view
        saveIBWeight(ampm: .am)
        saveIBWeight(ampm: .pm)
        
        // Switch to new date
        self.currentViewDateWeightEntry = date
        
        let recordAM = HealthSynchronizer.shared.syncWeightToShow(date: date, ampm: .am)
        timeAMEntry.text = recordAM.time
        weightAMEntry.text = recordAM.weight
        timePickerAM.setDate(date, animated: false)
        
        let recordPM = HealthSynchronizer.shared.syncWeightToShow(date: date, ampm: .pm)
        timePMEntry.text = recordPM.time
        weightPMEntry.text = recordPM.weight
        if timePickerPM != nil {
            timePickerPM.setDate(date, animated: false)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // weightAMEntry.endEditing(true)
        view.endEditing(true)
    }
    
}

// MARK: - UITextFieldDelegate

extension WeightEntryViewController: UIPickerViewDelegate {
    // pickerView
}

// MARK: - UITextFieldDelegate

extension WeightEntryViewController: UITextFieldDelegate {
    // :1:
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //LogService.shared.debug("textFieldShouldBeginEditing")
        
        // :===: should solve initial picker registration
        if textField.text == nil || textField.text!.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            // dateFormatter.setLocalizedDateFormatFromTemplate(<#T##dateFormatTemplate: String##String#>) :TBD:ToBeLocalized?
            if textField == timeAMEntry {
                timeAMEntry.text = dateFormatter.string(from: DateManager.currentDatetime())
            }
            if textField == timePMEntry {
                timePMEntry.text = dateFormatter.string(from: DateManager.currentDatetime())
            }
        }
        return true // return false to disallow editing.
    }
    // :2:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //LogService.shared.debug("textFieldDidBeginEditing")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //LogService.shared.debug("textFieldShouldReturn")
        //weightAMEntry.endEditing(true)
        view.endEditing(true)
        
        //textField.resignFirstResponder()
        return true
    }
    
    // :3:
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //LogService.shared.debug("textFieldShouldEndEditing")
        if textField.text != "" {
            return true
        } else {
            return false
        }
    }
    
    // :4:
    func textFieldDidEndEditing(_ textField: UITextField) {
        //this is where you might add other code
        //LogService.shared.debug("textFieldDidEndEditing")
        if let weight = weightAMEntry.text {
            LogService.shared.debug("•HK• WeightEntryViewController textFieldDidEndEditing \(weight)")
        }
    }
}

// MARK: - RealmDelegate

extension WeightEntryViewController: RealmDelegate {
    func didUpdateFile() {
        navigationController?.popViewController(animated: false)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
