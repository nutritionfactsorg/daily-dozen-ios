//
//  DozeDetailSection.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum DozeDetailSection: Int {
    
    private struct Nibs {
        static let amountHeaderNib = "DozeDetailSizeHeader"
        static let exampleHeaderNib = "DozeDetailTypeHeader"
    }
    
    case amount, example
    
    var rowHeight: CGFloat {
        switch self {
        case .amount:
            return 75
        case .example:
            return 75
        }
    }
    
    var headerHeight: CGFloat {
        switch self {
        case .amount:
            return 50 // :!!!:UNITS_VISIBILITY:
        case .example:
            return 50
        }
    }
    
    var headerView: UIView? {
        switch self {
        case .amount:
            // Handle imperial vs. metric units
            //let shouldHideTypeToggle = UserDefaults.standard.bool(forKey: SettingsKeys.unitsTypeTogglePref)// :!!!:UNITS_VISIBILITY:
            if let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
                let currentUnitsType = UnitsType(rawValue: unitsTypePrefStr),
                let uiView: UIView = Bundle.main
                    .loadNibNamed(Nibs.amountHeaderNib, owner: nil)?
                    .first as? UIView {
                let shouldHideTypeToggle = !UserDefaults.standard.bool(forKey: SettingsKeys.unitsTypeTogglePref) // :!!!:UNITS_VISIBILITY:
                //let shouldHideTypeToggle = true // :!!!:UNITS_VISIBILITY:DEBUG:
                print(UserDefaults.standard.bool(forKey: SettingsKeys.unitsTypeTogglePref))
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
        case .example:
            return Bundle.main
                .loadNibNamed(Nibs.exampleHeaderNib, owner: nil)?.first as? UIView
        }
    }
    
}
