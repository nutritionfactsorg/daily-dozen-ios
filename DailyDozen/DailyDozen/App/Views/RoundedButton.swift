//
//  RoundedButton.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 28.11.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

//@IBDesignable
class RoundedButton: UIButton {

    @IBInspectable
    var cornerRadius: CGFloat = 5 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable
    var borderWidth: CGFloat = 1 {
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
}
