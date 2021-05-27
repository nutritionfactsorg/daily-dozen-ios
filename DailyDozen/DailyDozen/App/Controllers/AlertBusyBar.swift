//
//  AlertBusyBar.swift
//  DailyDozen
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import Foundation
import UIKit

class AlertBusyBar: UIView {
    //
    private var _keyWindow: UIWindow!
    // elements
    private var _box: UIView!
    private var _label: UILabel!
    private var _progress: UIProgressView!
    
    init(parent: UIViewController) {
        _keyWindow = UIApplication.shared.keyWindowInConnectedScenes
        super.init(frame: _keyWindow.frame)
 
        setupView()
        setupConstraints()
    }
    
    /// use when view is instantiated in code (unimplemented)
    override init(frame: CGRect) {
        fatalError("AlertBusySpin init(frame:) not implemented")
        //super.init(frame: frame)
        //setupView()
        //setupConstraints()
    }
    
    /// use when view is created via the Interface Builder (unimplemented)
    required init?(coder: NSCoder) {
        fatalError("AlertBusySpin init(coder:) not implemented")
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
        
        _progress = UIProgressView()
        _progress.progressViewStyle = .default
        _progress.trackTintColor = UIColor.gray // not filled
        _progress.progressTintColor = UIColor.green // filled
        _box.addSubview(_progress)
    }
    
    private func setupConstraints() {
        // do *not* use old layout system
        _box.translatesAutoresizingMaskIntoConstraints = false
        _label.translatesAutoresizingMaskIntoConstraints = false
        _progress.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        // progress
        let progressTopAnchor = _progress.topAnchor
            .constraint(equalTo: _label.bottomAnchor, constant: 10)
        let progressHeightAnchor = _progress.heightAnchor
            .constraint(equalToConstant: 12.0)
        let progressLeadingAnchor = _progress.leadingAnchor
            .constraint(equalTo: _box.leadingAnchor, constant: 8)
        let progressTrailingAnchor = _progress.trailingAnchor
            .constraint(equalTo: _box.trailingAnchor, constant: -8)
        
        NSLayoutConstraint.activate([
            boxXAnchor, boxYAnchor, boxHeightAnchor, boxLeadingAnchor, boxTrailingAnchor,
            labelBottomAnchor, labelLeadingAnchor, labelTrailingAnchor,
            progressTopAnchor, progressHeightAnchor, progressLeadingAnchor, progressTrailingAnchor
        ])
    }
    
    func completed() {
        self.removeFromSuperview()
    }
    
    func setProgress(_ percent: Float) {
        _progress.setProgress(percent, animated: true)
        print(":!!!: progress=\(percent)")
    }
    
    func setText(_ s: String) {
        _label.text = s
    }
    
    func show() {
        _keyWindow.addSubview(self)
    }
    
}
