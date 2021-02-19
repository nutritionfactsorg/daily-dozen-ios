//
//  RoundedTextfield.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import UIKit

// @IBDesignable
class RoundedTextfield: UITextField {

    // MARK: - Actions
    
    @IBInspectable var isPasteEnabled: Bool = false
    @IBInspectable var isSelectEnabled: Bool = false
    @IBInspectable var isSelectAllEnabled: Bool = false
    @IBInspectable var isCopyEnabled: Bool = false
    @IBInspectable var isCutEnabled: Bool = false
    @IBInspectable var isDeleteEnabled: Bool = false

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(UIResponderStandardEditActions.paste(_:)) where isPasteEnabled,
             #selector(UIResponderStandardEditActions.select(_:)) where isSelectEnabled,
             #selector(UIResponderStandardEditActions.selectAll(_:)) where isSelectAllEnabled,
             #selector(UIResponderStandardEditActions.copy(_:)) where isCopyEnabled,
             #selector(UIResponderStandardEditActions.cut(_:)) where isCutEnabled,
             #selector(UIResponderStandardEditActions.delete(_:)) where isDeleteEnabled:
            return super.canPerformAction(action, withSender: sender)
        default:
            return false
        }
    }
    
    // MARK: - Appearance
    
    @IBInspectable
    var cornerRadius: CGFloat = 5 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable
    var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable
    var shadowColor: UIColor = UIColor.lightGray {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }

    @IBInspectable
    var shadowRadius: CGFloat = 1 {
        didSet {
            layer.shadowRadius = 1
        }
    }

    @IBInspectable
    var shadowOffset: CGSize = CGSize(width: 0, height: 2) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable
    var shadowOpacity: Float = 1 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    override var isEnabled: Bool {
        didSet {
            layer.borderColor = isEnabled ? borderColor.cgColor : borderColor.withAlphaComponent(0.5).cgColor
        }
    }
    
}
