//
//  WeightViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable file_length
// swiftlint:disable type_body_length
// swiftlint:disable function_body_length

import UIKit
import HealthKit

class WeightViewController: UIViewController {
    
    // MARK: - Outlets
    // Text Edit
    @IBOutlet weak var timeAMInput: UITextField!
    @IBOutlet weak var timePMInput: UITextField!
    @IBOutlet weak var weightAM: UITextField!
    @IBOutlet weak var weightPM: UITextField!
    
    @IBOutlet weak var weightAMLabel: UILabel!
    @IBOutlet weak var weightPMLabel: UILabel!
    
    // Buttons
    @IBOutlet weak var clearWeightAMButton: UIButton!
    @IBOutlet weak var saveWeightAMButton: UIButton!
    @IBOutlet weak var clearWeightPMButton: UIButton!
    @IBOutlet weak var saveWeightPMButton: UIButton!
    
    // MARK: - Properties
    private let realm = RealmProvider()
    private var currentViewDateFindMe = Date()
    private var timePickerAM: UIDatePicker?
    private var timePickerPM: UIDatePicker?
    
    var pidAM: String {
        return "\(currentViewDateFindMe.datestampKey).am"
    }
    
    var pidPM: String {
        return "\(currentViewDateFindMe.datestampKey).pm"
    }
    
    var pidWeight: String {
        return "\(currentViewDateFindMe.datestampKey).tweakWeightTwice"
    }
    
    // MARK: - Actions
    @IBAction func clearWeightAMButtonPressed(_ sender: Any) {
        // :NYI: confirm clear & delete
        view.endEditing(true)
        clearWeightAM()
    }
    
    func clearWeightAM() {
        timeAMInput.text = ""
        weightAM.text = ""
        // :NYI: clear HealthKit value
        realm.deleteWeight(date: currentViewDateFindMe, weightType: .am)
        updateWeightDataCount()
    }
    
    @IBAction func saveWeightAMButtonPressed(_ sender: Any) {
        view.endEditing(true)
        saveWeightAM()
    }
    
    func saveWeightAM() {
        let datestampKey = currentViewDateFindMe.datestampKey
        // am
        if
            let amTimeText = timeAMInput.text,
            let amDate = Date(healthkit: "\(datestampKey) \(amTimeText)"),
            let amWeightText = weightAM.text,
            var amWeight = Double(amWeightText),
            amWeight > 5.0 {
            
            // Update HealthKit
            HealthManager.shared.submitWeight(weight: amWeight, forDate: amDate)
            
            // Update local data
            if isImperial() {
                amWeight = amWeight / 2.2046 // kg = lbs * 2.2046
            }
            realm.saveWeight(date: amDate, weightType: .am, kg: amWeight)
            // Update local counter
        }
        updateWeightDataCount()
    }
    
    @IBAction func clearWeightPMButtonPressed(_ sender: Any) {
        // :NYI: confirm clear & delete
        view.endEditing(true)
        clearWeightPM()
    }
    
    func clearWeightPM() {
        timePMInput.text = ""
        weightPM.text = ""
        // :NYI: clear HealthKit value
        realm.deleteWeight(date: currentViewDateFindMe, weightType: .pm)
        updateWeightDataCount()
    }
    
    @IBAction func saveWeightPMButtonPressed(_ sender: Any) {
        view.endEditing(true)
        saveWeightPM()
    }
    
    func saveWeightPM() {
        let datestampKey = currentViewDateFindMe.datestampKey
        // pm
        if
            let pmTimeText = timePMInput.text,
            let pmDate = Date(healthkit: "\(datestampKey) \(pmTimeText)"),
            let pmWeightText = weightPM.text,
            var pmWeight = Double(pmWeightText),
            pmWeight > 5.0 {
            
            // Update HealthKit
            HealthManager.shared.submitWeight(weight: pmWeight, forDate: pmDate)
            // Update local data
            if isImperial() {
                pmWeight = pmWeight / 2.2046 // kg = lbs * 2.2046
            }
            realm.saveWeight(date: pmDate, weightType: .pm, kg: pmWeight)
            // Update local counter
        }
        updateWeightDataCount()
    }
    
    private func updateWeightDataCount() {
        let records = realm.getDailyWeight(date: currentViewDateFindMe)
        var count = 0
        if records.am != nil {
            count += 1
        }
        if records.pm != nil {
            count += 1
        }
        
        realm.saveCount(count, date: currentViewDateFindMe, countType: .tweakWeightTwice)
    }
    
    // Note: call once upon entry from tweaks checklist or history
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weightPM.delegate = self
        weightAM.delegate = self
        timeAMInput.delegate = self
        timePMInput.delegate = self
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.realmDelegate = self
        
        // AM Morning
        // :===: timePickerAM = UIDatePicker() // may need contraints?
        timePickerAM = UIDatePicker(frame: CGRect())
        timePickerAM?.datePickerMode = .time
        timePickerAM?.addTarget(self, action: #selector(WeightViewController.timeChangedAM(timePicker:)), for: .valueChanged)
        
        timeAMInput.inputView = timePickerAM // assign initial value
        
        // PM Evening
        timePickerPM = UIDatePicker()
        timePickerPM?.datePickerMode = .time
        timePickerPM?.addTarget(self, action: #selector(WeightViewController.timeChangedPM(timePicker:)), for: .valueChanged)
        timePMInput.inputView = timePickerPM
        
        setViewModel(viewDate: Date())
        
        // Unit Type
        if isImperial() {
            weightAMLabel.text = "lbs."
            weightPMLabel.text = "lbs."
        } else {
            weightAMLabel.text = "kg"
            weightPMLabel.text = "kg"
        }
        
        //
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(WeightViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMorningHKData(notification:)),
            name: NSNotification.Name(rawValue: "MorningBodyMassDataAvailable"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateEveningHKData(notification:)),
            name: NSNotification.Name(rawValue: "EveningBodyMassDataAvailable"),
            object: nil)
    }
    
    @objc func updateMorningHKData(notification: Notification) {
        
        guard let weightArray = notification.object as? [HKQuantitySample],
            weightArray.count > 0 else {
                return
        }
        
        for someElement: HKQuantitySample in weightArray {
            let bodyMassKg = someElement.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            let dateStr = dateFormatter.string(from: someElement.endDate)
            if dateStr.suffix(2).lowercased() == "am" {
                timeAMInput.text = dateStr
                var amWeight = Double(bodyMassKg)
                if isImperial() {
                    amWeight = amWeight * 2.2046 // kg = lbs * 2.2046
                }
                weightAM.text = String(format: "%.2f", amWeight)
            }
            return
        }
    }
    
    @objc func updateEveningHKData(notification: Notification) {
        guard let weightArray = notification.object as? [HKQuantitySample],
            weightArray.count > 0 else {
                return
        }
        print(weightArray[0])
        for someElement: HKQuantitySample in weightArray {
            let bodyMassKg = someElement.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            let dateStr = dateFormatter.string(from: someElement.endDate)
            if dateStr.suffix(2).lowercased() == "pm" {
                timePMInput.text = dateStr
                var pmWeight = Double(bodyMassKg)
                if isImperial() {
                    pmWeight = pmWeight * 2.2046 // 1 kg =  2.2046 lb
                }
                weightPM.text = String(format: "%.2f", pmWeight)
            }
            return
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Update stored values
        saveWeightAM()
        saveWeightPM()
    }
    
    func getTimeNow() -> String {
        let dateNow = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
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
        timePicker.minimumDate = min
        timePicker.maximumDate = max
        timeAMInput.text = dateFormatter.string(from: timePicker.date)
        //view.endEditing(true)
    }
    
    @objc func timeChangedPM(timePicker: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        timePMInput.text = dateFormatter.string(from: timePicker.date)
        view.endEditing(true)
    }
    
    /// Set the current date.
    ///
    /// Note: updated by pager.
    ///
    /// - Parameter item: sets the current date.
    func setViewModel(viewDate: Date) {
        // Update stored values
        saveWeightAM()
        saveWeightPM()
        
        // Switch to new date
        self.currentViewDateFindMe = viewDate
        let records = realm.getDailyWeight(date: currentViewDateFindMe)
        
        if let amRecord = records.am {
            timeAMInput.text = amRecord.timeAmPm
            if isImperial() {
                weightAM.text = String(format: "%.1f", amRecord.lbs)
            } else {
                weightAM.text = String(format: "%.1f", amRecord.kg)
            }
            if let date = amRecord.datetime {
                timePickerAM?.setDate(date, animated: false)
            }
        } else {
            let now = Date()
            if viewDate.datestampKey == now.datestampKey {
                let start = Calendar.current.startOfDay(for: viewDate)
                var components = DateComponents()
                components.day = 1
                components.second = -1
                let end = Calendar.current.date(byAdding: components, to: start)!
                HealthManager.shared.fetchWeightDataMorning(startDate: start, endDate: end)
                //HealthManager.shared.fetchWeightDataMorning()
            } else {
                print("setViewModel() viewDate:\n\(viewDate)")
                let start = Calendar.current.startOfDay(for: viewDate)
                print("setViewModel() start:\n\(start)")
                var components = DateComponents()
                components.day = 1
                components.second = -1
                let end = Calendar.current.date(byAdding: components, to: start)!
                print("setViewModel() end:\n\(end))")
                HealthManager.shared.fetchWeightDataMorning(startDate: start, endDate: end)
            }
            timeAMInput.text = ""
            weightAM.text = ""
            timePickerAM?.setDate(Date(), animated: false)
        }
        
        if let pmRecord = records.pm {
            timePMInput.text = pmRecord.timeAmPm
            if isImperial() {
                weightPM.text = String(format: "%.1f", pmRecord.lbs)
            } else {
                weightPM.text = String(format: "%.1f", pmRecord.kg)
            }
            if let date = pmRecord.datetime {
                timePickerPM?.setDate(date, animated: false)
            }
        } else {
            //let now = Date()
            //            if viewDate.datestampKey == now.datestampKey {
            //                HealthManager.shared.fetchWeightDataEvening()
            //            }
            let start = Calendar.current.startOfDay(for: viewDate)
            var components = DateComponents()
            components.day = 1
            components.second = -1
            let end = Calendar.current.date(byAdding: components, to: start)!
            HealthManager.shared.fetchWeightDataEvening(startDate: start, endDate: end)
            timePMInput.text = ""
            weightPM.text = ""
            timePickerPM?.setDate(Date(), animated: false)
        }
    }
    
    private func isImperial() -> Bool {
        guard
            let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
            let currentUnitsType = UnitsType(rawValue: unitsTypePrefStr)
            else {
                return true
        }
        if currentUnitsType == .imperial {
            return true
        }
        return false
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
        // weightAM.endEditing(true)
        view.endEditing(true)
    }
    
}

// MARK: - UITextFieldDelegate

extension WeightViewController: UIPickerViewDelegate {
    // pickerView
}

// MARK: - UITextFieldDelegate

extension WeightViewController: UITextFieldDelegate {
    // :1:
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //print("textFieldShouldBeginEditing")
        
        // :===: should solve initial picker registration
        if textField.text == nil || textField.text!.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            if textField == timeAMInput {
                timeAMInput.text = dateFormatter.string(from: Date())
            }
            if textField == timePMInput {
                timePMInput.text = dateFormatter.string(from: Date())
            }
        }
        return true // return NO to disallow editing.
    }
    // :2:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //print("textFieldDidBeginEditing")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print("textFieldShouldReturn")
        //weightAM.endEditing(true)
        view.endEditing(true)
        
        //textField.resignFirstResponder()
        return true
    }
    
    // :3:
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //print("textFieldShouldEndEditing")
        if textField.text != "" {
            return true
        } else {
            return false
        }
    }
    
    // :4:
    func textFieldDidEndEditing(_ textField: UITextField) {
        //this is where you might add other code
        //print("textFieldDidEndEditing")
        if let weight = weightAM.text {
            print(weight)
        }
    }
}

// MARK: - RealmDelegate

extension WeightViewController: RealmDelegate {
    func didUpdateFile() {
        navigationController?.popViewController(animated: false)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
