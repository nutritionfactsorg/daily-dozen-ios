//
//  UtilityPickerView.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable function_body_length

import UIKit

class PopupPickerView: NSObject, UIPickerViewDelegate, UIPickerViewDataSource { // UIPickerView
    
    // MARK: - UIPickerView
    
    /* UIPickerView
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    //Theme colors
    var itemTextColor = UIColor.black
    var backgroundColor = UIColor.orange.withAlphaComponent(0.5)
    var toolBarColor = UIColor.blue
    var font = UIFont.systemFont(ofSize: 16)
    
    private static var shared: PopupPickerView!
    var bottomAnchorOfPickerView: NSLayoutConstraint!
    var heightOfPickerView: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 160 : 120
    var heightOfToolbar: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 50 : 40
    
    var dataSource: (items: [String]?, itemIds: [String]?)
    
    typealias CompletionBlock = (_ item: String?, _ id: String?) -> Void
    var didSelectCompletion: CompletionBlock?
    var doneBottonCompletion: CompletionBlock?
    var cancelBottonCompletion: CompletionBlock?
    
    lazy var pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.delegate = self
        pv.dataSource = self
        pv.showsSelectionIndicator = true
        pv.backgroundColor = self.backgroundColor
        return pv
    }()
    
    lazy var disablerView: UIView={
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    lazy var tooBar: UIView={
        let view = UIView()
        view.backgroundColor = self.toolBarColor
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
    
    lazy var buttonDone: UIButton={
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.tintColor = self.itemTextColor
        button.titleLabel?.font = self.font
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(self.buttonDoneClicked), for: .touchUpInside)
        return button
    }()
    
    lazy var buttonCancel: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.tintColor = self.itemTextColor
        button.titleLabel?.font = self.font
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(self.buttonCancelClicked), for: .touchUpInside)
        return button
    }()
    
    static func show(items: [String], itemIds: [String]? = nil, selectedValue: String? = nil, doneBottonCompletion: CompletionBlock?, didSelectCompletion: CompletionBlock?, cancelBottonCompletion: CompletionBlock?) {
        
        if PopupPickerView.shared == nil {
            shared = PopupPickerView()
        } else {
            return
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, 
            let keyWindow = appDelegate.window {
            
            shared.cancelBottonCompletion = cancelBottonCompletion
            shared.didSelectCompletion = didSelectCompletion
            shared.doneBottonCompletion = doneBottonCompletion
            shared.dataSource.items = items
            
            if let idsVal = itemIds, items.count == idsVal.count { //ids can not be less or more than items
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
            
            shared.disablerView.addSubview(shared.tooBar)
            shared.tooBar.heightAnchor.constraint(equalToConstant: shared.heightOfToolbar).isActive = true
            shared.tooBar.leftAnchor.constraint(equalTo: shared.disablerView.leftAnchor, constant: 0).isActive = true
            shared.tooBar.rightAnchor.constraint(equalTo: shared.disablerView.rightAnchor, constant: 0).isActive = true
            shared.tooBar.bottomAnchor.constraint(equalTo: shared.pickerView.topAnchor, constant: 0).isActive = true
            
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let names = dataSource.items {
            return names[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if let names = dataSource.items {
            let item = names[row]
            return NSAttributedString(string: item, attributes: [NSAttributedString.Key.foregroundColor: itemTextColor, NSAttributedString.Key.font: font])
        }
        return nil
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
    
    @objc func buttonDoneClicked() {
        self.hidePicker(handler: doneBottonCompletion)
    }
    
    @objc func buttonCancelClicked() {
        self.hidePicker(handler: cancelBottonCompletion)
    }
    
    func hidePicker(handler: CompletionBlock?) {
        var itemName: String?
        var id: String?
        let row = self.pickerView.selectedRow(inComponent: 0)
        if let names = dataSource.items {
            itemName = names[row]
        }
        if let ids = dataSource.itemIds {
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
                PopupPickerView.shared = nil}
        )
    }
    
}
