//
//  UtilityPickerView.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable function_body_length

import UIKit

class ImportPopupPickerView: NSObject, UIPickerViewDelegate, UIPickerViewDataSource { // UIPickerView
    
    // MARK: - UIPickerView
    
    /* UIPickerView
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    // Button Text
    var buttonCancelTitle = NSLocalizedString("history_data_alert_cancel", comment: "Cancel")
    var buttonDoneTitle = NSLocalizedString("history_data_alert_ok", comment: "OK")
    
    // Theme colors
    var headerBackgroundColor = ColorManager.style.pickerHeaderBackground
    var headerFont = UIFont.helevetica17
    var headerTextColor = ColorManager.style.pickerHeaderText
    var scrollBackgroundColor = ColorManager.style.pickerScrollBackground
    var scrollFont = UIFont.courier16
    var scrollTextColor = ColorManager.style.pickerScrollText
    
    private static var shared: ImportPopupPickerView!
    var bottomAnchorOfPickerView: NSLayoutConstraint!
    var heightOfPickerView: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 160 : 120
    var heightOfToolbar: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 50 : 40
    
    var dataSource: (items: [String]?, itemIds: [String]?)
    
    typealias CompletionBlock = (_ item: String?, _ id: String?) -> Void
    var didSelectCompletion: CompletionBlock?
    var doneButtonCompletion: CompletionBlock?
    var cancelButtonCompletion: CompletionBlock?
    
    lazy var pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.delegate = self
        pv.dataSource = self
        pv.backgroundColor = self.scrollBackgroundColor
        return pv
    }()
    
    lazy var disablerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    lazy var pickerToolbar: UIView = {
        let view = UIView()
        view.backgroundColor = self.headerBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonDone)
        buttonDone.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        buttonDone.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        buttonDone.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        buttonDone.widthAnchor.constraint(equalToConstant: 65).isActive = true
        
        view.addSubview(buttonCancel)
        buttonCancel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        buttonCancel.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        buttonCancel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        buttonCancel.widthAnchor.constraint(equalToConstant: 65).isActive = true
        
        return view
    }()
    
    lazy var buttonDone: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(buttonDoneTitle, for: .normal)
        button.tintColor = self.headerTextColor
        button.titleLabel?.font = self.headerFont
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(self.buttonDoneClicked), for: .touchUpInside)
        return button
    }()
    
    lazy var buttonCancel: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(buttonCancelTitle, for: .normal)
        button.tintColor = self.headerTextColor
        button.titleLabel?.font = self.headerFont
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(self.buttonCancelClicked), for: .touchUpInside)
        return button
    }()
    
    static func show(cancelTitle: String? = nil, doneTitle: String? = nil, items: [String], itemIds: [String]? = nil, selectedValue: String? = nil, doneButtonCompletion: CompletionBlock?, didSelectCompletion: CompletionBlock?, cancelButtonCompletion: CompletionBlock?) {
        
        if ImportPopupPickerView.shared == nil {
            shared = ImportPopupPickerView()
        } else {
            return
        }
        
        if let cancelTitle = cancelTitle {
            shared.buttonCancelTitle = cancelTitle
        }
        if let doneTitle = doneTitle {
            shared.buttonDoneTitle = doneTitle
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, 
            let keyWindow = appDelegate.window {
            
            shared.cancelButtonCompletion = cancelButtonCompletion
            shared.didSelectCompletion = didSelectCompletion
            shared.doneButtonCompletion = doneButtonCompletion
            shared.dataSource.items = items
            
            if let idsVal = itemIds, items.count == idsVal.count {
                shared?.dataSource.itemIds  = itemIds
            }
            
            shared?.heightOfPickerView += shared.heightOfToolbar
            
            keyWindow.addSubview(shared.disablerView)
            shared.disablerView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: 0).isActive = true
            shared.disablerView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor, constant: 0).isActive = true
            shared.disablerView.topAnchor.constraint(equalTo: keyWindow.topAnchor, constant: 0).isActive = true
            shared.disablerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor, constant: 0).isActive = true
            
            shared.disablerView.addSubview(shared.pickerView)
            shared.pickerView.leftAnchor.constraint(equalTo: shared.disablerView.leftAnchor, constant: 0).isActive = true
            shared.pickerView.rightAnchor.constraint(equalTo: shared.disablerView.rightAnchor, constant: 0).isActive = true
            shared.pickerView.heightAnchor.constraint(equalToConstant: shared.heightOfPickerView).isActive = true
            shared.bottomAnchorOfPickerView = shared.pickerView.topAnchor.constraint(equalTo: shared.disablerView.bottomAnchor, constant: 0)
            shared.bottomAnchorOfPickerView.isActive = true
            
            shared.disablerView.addSubview(shared.pickerToolbar)
            shared.pickerToolbar.heightAnchor.constraint(equalToConstant: shared.heightOfToolbar).isActive = true
            shared.pickerToolbar.leftAnchor.constraint(equalTo: shared.disablerView.leftAnchor, constant: 0).isActive = true
            shared.pickerToolbar.rightAnchor.constraint(equalTo: shared.disablerView.rightAnchor, constant: 0).isActive = true
            shared.pickerToolbar.bottomAnchor.constraint(equalTo: shared.pickerView.topAnchor, constant: 0).isActive = true
            
            keyWindow.layoutIfNeeded()
            
            if let selectedVal = selectedValue {
                for (index, itemName) in items.enumerated() {
                    if itemName.lowercased() == selectedVal.lowercased() {
                        shared.pickerView.selectRow(index, inComponent: 0, animated: false)
                        break
                    }
                }
            }
            
            shared.bottomAnchorOfPickerView.constant = -shared.heightOfPickerView
            
            UIView.animate(
                withDuration: 0.5, 
                delay: 0, 
                usingSpringWithDamping: 1, 
                initialSpringVelocity: 1, 
                options: .curveEaseOut, 
                animations: {
                    keyWindow.layoutIfNeeded()
                    shared.disablerView.alpha = 1}, 
                completion: { (_: Bool) in  }
            )
            
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let count = dataSource.items?.count {
            return count
        }
        return 0
    }
    
    // MARK: - UIPickerViewDelegate
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if let names = dataSource.items {
//            return names[row]
//        }
//        return nil
//    }
    
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        
//        if let names = dataSource.items {
//            let itemStr = names[row] + ".this.that.ext"
//            let attributes: [NSAttributedString.Key: Any] = [
//                NSAttributedString.Key.foregroundColor: self.scrollTextColor,
//                NSAttributedString.Key.font: self.scrollFont
//            ]
//            // init(markdown:options:baseURL:)' requires iOS 15 or newer
//            let aStr = NSAttributedString(string: itemStr, attributes: attributes)
//            return aStr
//        }
//        return nil
//    }
    
    // UIView based
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerData: [String]!
        if let names = dataSource.items {
            pickerData = names
        } else {
            pickerData = ["?"]
        }
        
        var pickerLabel: UILabel!
        if view == nil { // if no label yet
            pickerLabel = UILabel()
            //color the label's background
            //let hue = CGFloat(row)/CGFloat(pickerData.count)
            //pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            pickerLabel.backgroundColor  = scrollBackgroundColor
        }
        if let view = view as? UILabel {
            pickerLabel = view
        } else {
            pickerLabel = UILabel()
            pickerLabel.backgroundColor  = scrollBackgroundColor
        }
        
        let titleData = pickerData[row]
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: scrollFont,
            NSAttributedString.Key.foregroundColor: scrollTextColor
        ]
        let title = NSAttributedString(string: titleData, attributes: attributes)
        pickerLabel.attributedText = title
        pickerLabel.textAlignment = .center
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var itemName: String?
        var id: String?
        
        if let names = dataSource.items {
            itemName = names[row]
        }
        if let ids = dataSource.itemIds {
            id = ids[row]
        }
        self.didSelectCompletion?(itemName, id)
    }
        
    // MARK: - 

    @objc func buttonDoneClicked() {
        self.hidePicker(handler: doneButtonCompletion)
    }
    
    @objc func buttonCancelClicked() {
        self.hidePicker(handler: cancelButtonCompletion)
    }
    
    func hidePicker(handler: CompletionBlock?) {
        var itemName: String?
        var id: String?
        let row = self.pickerView.selectedRow(inComponent: 0)
        if let names = dataSource.items, names.isEmpty == false {
            itemName = names[row]
        }
        if let ids = dataSource.itemIds, ids.isEmpty == false {
            id = ids[row]
        }
        handler?(itemName, id)
        
        bottomAnchorOfPickerView.constant = self.heightOfPickerView
        UIView.animate(
            withDuration: 0.7, 
            delay: 0, 
            usingSpringWithDamping: 1, 
            initialSpringVelocity: 1, 
            options: .curveEaseOut, 
            animations: {
                self.disablerView.window!.layoutIfNeeded()
                self.disablerView.alpha = 0},
            completion: { (_: Bool) in
                self.disablerView.removeFromSuperview()
                ImportPopupPickerView.shared = nil}
        )
    }
    
}
