//
//  UITextFieldExtension.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import UIKit

extension UITextField {
    /// Assign DatePicker to Text Field `inputView`
    func datePicker<T>(
        target: T,
        doneAction: Selector,
        cancelAction: Selector,
        datePickerMode: UIDatePicker.Mode = .date
    ) {
        let screenWidth = UIScreen.main.bounds.width
                
        let datePicker = UIDatePicker()
        datePicker.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 216)
        datePicker.datePickerMode = datePickerMode
        if #available(iOS 14, *) { // Added condition for iOS 14 and above
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        self.inputView = datePicker
        // self.selectedTextRange = nil // does not hid caret
        // self.allowsEditingTextAttributes = false // does not hide caret
        
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 44)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: target, action: cancelAction)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: doneAction)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, flexSpace, doneButton], animated: true)
        self.inputAccessoryView = toolBar
    }
    
}
