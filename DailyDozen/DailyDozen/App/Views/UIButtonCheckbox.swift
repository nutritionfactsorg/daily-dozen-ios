//
//  UIButtonCheckbox.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

@IBDesignable open class UIButtonCheckbox: UIButton {

// MARK: - Parameters
    
    /// Checkbox border color
    @IBInspectable var borderColor: UIColor = UIColor.greenLightColor {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    /// Checkbox border width
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    /// Checkbox corner radius
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    /// Checkbox boundary padding
    @IBInspectable var padding: CGFloat = CGFloat(15)

    var checkboxImage: UIImage?

    // MARK: - Init

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDefaultParams()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initDefaultParams()
    }
        
    /// Checked/Unchecked status variable
    override open var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            onSelectStateChanged?(self, isSelected)
            
            setBackgroundImage(isSelected ? checkboxImage : nil, for: .normal)
        }
    }

    /// Checkbox status change callback
    open var onSelectStateChanged: ((_ checkbox: UIButtonCheckbox, _ selected: Bool) -> Void)?

    /// Increase clickable pointing area
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        let newBound = CGRect(
            x: self.bounds.origin.x - padding,
            y: self.bounds.origin.y - padding,
            width: self.bounds.width + 2 * padding,
            height: self.bounds.width + 2 * padding
        )
        
        return newBound.contains(point)
    }
    
    override open func prepareForInterfaceBuilder() {
        setTitle("", for: UIControl.State())
    }
 
}

// MARK: - Private methods

public extension UIButtonCheckbox {

    fileprivate func initDefaultParams() {
        addTarget(self, action: #selector(UIButtonCheckbox.checkboxTapped), for: .touchUpInside)
        setTitle(nil, for: UIControl.State())

        clipsToBounds = true

        setCheckboxImage()
    }

    fileprivate func setCheckboxImage() {
        // Image background color must match `*StateCell` border color
        // See `*StateCell` configure(…) for details.
        let image = UIImage(named: "ic_checkmark_fill")
        imageView?.contentMode = .scaleAspectFit
        self.checkboxImage = image
    }

    @objc fileprivate func checkboxTapped(_ sender: UIButtonCheckbox) {
        isSelected = !isSelected
    }
}
