//
//  TweakDetailSection.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum TweakDetailSection: Int {
    
    private struct Nibs {
        static let tweakActivityHeaderNib = "TweakDetailActivityHeader"
        static let tweakDescriptionHeaderNib = "TweakDetailDescriptionHeader"
    }
    
    case activity, description
    
    var rowHeight: CGFloat {
        switch self {
        case .activity:
            return 75
        case .description:
            return 75
        }
    }
    
    var headerHeight: CGFloat {
        switch self {
        case .activity:
            return 50 // :!!!:UNITS_VISIBILITY:
        case .description:
            return 50
        }
    }
        
    var headerTweaksView: UIView? {
        switch self {
        case .activity:
            // Handle imperial vs. metric units
            if let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
                let currentUnitsType = UnitsType(rawValue: unitsTypePrefStr),
                let uiView: UIView = Bundle.main
                    .loadNibNamed(Nibs.tweakActivityHeaderNib, owner: nil)?
                    .first as? UIView {
                let shouldHideTypeToggle = !UserDefaults.standard.bool(forKey: SettingsKeys.unitsTypeTogglePref) // :!!!:UNITS_VISIBILITY:
                for subview1 in uiView.subviews {
                    if let stackView1 = subview1 as? UIStackView {
                        for subview2 in stackView1.subviews {
                            if let stackView2 = subview2 as? UIStackView {
                                for subview3 in stackView2.subviews {
                                    if let button = subview3 as? UIButton {
                                        button.setTitle(currentUnitsType.title, for: .normal)
                                        button.isHidden = shouldHideTypeToggle // :!!!:UNITS_VISIBILITY:
                                    }
                                    if let label = subview3 as? UILabel {
                                       label.isHidden = shouldHideTypeToggle // :!!!:UNITS_VISIBILITY:
                                    }
                                }
                            }
                        }
                    }
                }
                return uiView
            }
            return nil
        case .description:
            return Bundle.main
                .loadNibNamed(Nibs.tweakDescriptionHeaderNib, owner: nil)?.first as? UIView
        }
    }
    
}
