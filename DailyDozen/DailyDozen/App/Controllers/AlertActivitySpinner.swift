//
//  AlertActivitySpinner.swift
//  DailyDozen
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import Foundation
import UIKit

class AlertActivitySpinner: UIView, ActivityProgress {
    //
    private var _keyWindow: UIWindow!
    // elements
    private var _box: UIView!
    private var _label: UILabel!
    private var _spinner: UIActivityIndicatorView!
    
    init() {
        _keyWindow = UIApplication.shared.keyWindowInConnectedScenes
        super.init(frame: _keyWindow.frame)
 
        setupView()
        setupConstraints()
    }
    
    /// use when view is instantiated in code (unimplemented)
    override init(frame: CGRect) {
        fatalError("AlertActivitySpinner init(frame:) not implemented")
        //super.init(frame: frame)
        //setupView()
        //setupConstraints()
    }
    
    /// use when view is created via the Interface Builder (unimplemented)
    required init?(coder: NSCoder) {
        fatalError("AlertActivitySpinner init(coder:) not implemented")
        //super.init(coder: coder)
        //setupView()
        //setupConstraints()
    }
    
    private func setupView() {
        _box = UIView()
        _box.isOpaque = true
        _box.alpha = 1.0
        _box.layer.borderColor = UIColor.lightGray.cgColor
        _box.layer.borderWidth = 2
        _box.backgroundColor = UIColor.white
        _box.layer.cornerRadius = 6
        self.addSubview(_box)
        
        _label = UILabel()
        _label.textAlignment = .center
        _box.addSubview(_label)
        
        _spinner = UIActivityIndicatorView()
        _spinner.color = ColorManager.style.mainForeground
        _box.addSubview(_spinner)
    }
    
    private func setupConstraints() {
        // do *not* use old layout system
        _box.translatesAutoresizingMaskIntoConstraints = false
        _label.translatesAutoresizingMaskIntoConstraints = false
        _spinner.translatesAutoresizingMaskIntoConstraints = false
        
        let guides: UILayoutGuide = layoutMarginsGuide
        //let margins: NSDirectionalEdgeInsets = directionalLayoutMargins
        
        // label
        let boxXAnchor = _box.centerXAnchor
            .constraint(equalTo: self.centerXAnchor)
        let boxYAnchor = _box.centerYAnchor
            .constraint(equalTo: self.centerYAnchor)
        let boxHeightAnchor = _box.heightAnchor
            .constraint(equalToConstant: 64.0)
        let boxLeadingAnchor = _box.leadingAnchor
            .constraint(equalTo: guides.leadingAnchor, constant: 4)
        let boxTrailingAnchor = _box.trailingAnchor
            .constraint(equalTo: guides.trailingAnchor, constant: -4)

        let labelBottomAnchor = _label.bottomAnchor
            .constraint(equalTo: _box.centerYAnchor)
        let labelLeadingAnchor = _label.leadingAnchor
            .constraint(equalTo: _box.leadingAnchor, constant: 8)
        let labelTrailingAnchor = _label.trailingAnchor
            .constraint(equalTo: _box.trailingAnchor, constant: -8)
        
        // spinner
        let spinnerTopAnchor = _spinner.topAnchor
            .constraint(equalTo: _label.bottomAnchor, constant: 10)
        let spinnerHeightAnchor = _spinner.heightAnchor
            .constraint(equalToConstant: 12.0)
        let spinnerLeadingAnchor = _spinner.leadingAnchor
            .constraint(equalTo: _box.leadingAnchor, constant: 8)
        let spinnerTrailingAnchor = _spinner.trailingAnchor
            .constraint(equalTo: _box.trailingAnchor, constant: -8)
        
        NSLayoutConstraint.activate([
            boxXAnchor, boxYAnchor, boxHeightAnchor, boxLeadingAnchor, boxTrailingAnchor,
            labelBottomAnchor, labelLeadingAnchor, labelTrailingAnchor,
            spinnerTopAnchor, spinnerHeightAnchor, spinnerLeadingAnchor, spinnerTrailingAnchor
        ])
    }
    
    func completed() {
        DispatchQueue.main.async {
            self._spinner.stopAnimating()
            self.removeFromSuperview()
        }
    }
    
    func setProgress(_ percent: Float) {
        // no progress value to set
    }
    
    func setText(_ s: String) {
        _label.text = s
    }
    
    func show() {
        _spinner.startAnimating()
        _keyWindow.addSubview(self)
    }
    
}
