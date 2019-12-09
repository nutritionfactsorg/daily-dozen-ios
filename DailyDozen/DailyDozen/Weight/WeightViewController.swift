//
//  WeightViewController.swift
//  DailyDozen
//
//  Created by marc on 2019.12.08.
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit
import StoreKit

class WeightViewController: UIViewController {
    
    // MARK: - Outlets
    // :---: Text Edit
    @IBOutlet weak var timeAMInput: UITextField!
    @IBOutlet weak var timePMInput: UITextField!
    @IBOutlet weak var weightAM: UITextField!
    @IBOutlet weak var weightPM: UITextField!
    
    @IBOutlet weak var saveButtonPressed: UIButton!
    @IBAction func cancelButtonPressed(_ sender: Any) {
    }
    // MARK: - Properties
    private let realm = RealmProvider()
    private let weightStateCountMaximum = 24
    private var timePickerAM: UIDatePicker?
    private var timePickerPM: UIDatePicker?
        
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        weightPM.delegate = self
        weightAM.delegate = self
        setViewModel(for: Date())
        
        // :---:
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.realmDelegate = self
        
        // AM Morning
        timePickerAM = UIDatePicker(frame: CGRect())
        timePickerAM?.datePickerMode = .time
        timePickerAM?.addTarget(self, action: #selector(WeightViewController.timeChangedAM(timePicker:)), for: .valueChanged)
        
        timeAMInput.inputView = timePickerAM
        
        // PM Evening
        timePickerPM = UIDatePicker()
        timePickerPM?.datePickerMode = .time
        timePickerPM?.addTarget(self, action: #selector(WeightViewController.timeChangedPM(timePicker:)), for: .valueChanged)
        timePMInput.inputView = timePickerPM
        
        //
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(WeightViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
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
        let min = dateFormatter.date(from: "12:00")      //createing min time
        let max = dateFormatter.date(from: "11:59")
        dateFormatter.dateFormat = "HH:mm a"
       timePicker.minimumDate = min
        timePicker.maximumDate = max
        timeAMInput.text = dateFormatter.string(from: timePicker.date)
        //view.endEditing(true)
    }
    
    @objc func timeChangedPM(timePicker: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a"
        timePMInput.text = dateFormatter.string(from: timePicker.date)
        view.endEditing(true)
    }
    ///
    /// - Parameter item: The current date.
    func setViewModel(for date: Date) {
        
        // :---: get the data for this date
        
        // :---: short the data for this date

    }
    
    // MARK: - Actions
    
    // :---: saveButton
    
    // :---: cancelButton
    
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
extension WeightViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //weightAM.endEditing(true)
        view.endEditing(true)
        
        //textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true} else {
            
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //this is where you might add other code
        if let weight = weightAM.text {
         print(weight)
        }
    }
    

}

extension WeightViewController: RealmDelegate {
    func didUpdateFile() {
        navigationController?.popViewController(animated: false)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
