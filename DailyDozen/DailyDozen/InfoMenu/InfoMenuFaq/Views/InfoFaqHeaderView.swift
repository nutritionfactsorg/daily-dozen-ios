//
//  InfoFaqHeaderView.swift
//  DailyDozen
//
//  Copyright © 2023 Nutritionfacts.org. All rights reserved.
//

import Foundation
import UIKit

final class InfoFaqHeaderView: UIView {
    
    private let faqHeaderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = NSLocalizedString("faq_title", comment: "")
        lbl.accessibilityIdentifier = "faq_title_access"
        
        lbl.font = UIFont.fontSystemBold22
        lbl.backgroundColor = ColorManager.style.mainMedium
        lbl.tintColor = ColorManager.style.mainMedium
        lbl.textColor = ColorManager.style.textWhite
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        placeContent(in: self)
        self.backgroundColor = ColorManager.style.mainMedium
    }
    
    /// use when view is created via the Interface Builder (unimplemented)
    required init?(coder: NSCoder) {
        fatalError("InfoFaqHeaderView init?(coder:) not implemented")
        //super.init(coder: coder)
        //setupView()
        //setupConstraints()
    }
    
    private func placeContent(in view: UIView) {
        view.addSubview(faqHeaderLabel)
        
        faqHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let height = heightAnchor.constraint(equalToConstant: 100)
        height.priority = .required - 1 // Avoid temporary resizing conflicts during
        
        NSLayoutConstraint.activate([
            faqHeaderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            faqHeaderLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            faqHeaderLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            faqHeaderLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            
            height
            //heightConstraint
        ])
        
    }
    
}
