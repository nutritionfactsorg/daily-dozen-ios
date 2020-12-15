//
//  RoundedTextfield.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import UIKit

//@IBDesignable
class RoundedTextfield: UITextField {

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
