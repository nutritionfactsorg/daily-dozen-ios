//
//  DozeDetailSections.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum DozeDetailSections: Int {
    
    private struct Nibs {
        static let amountHeaderNib = "DozeDetailSizeHeader"
        static let amountHeaderUnitNib = "DozeDetailSizeUnitHeader"
        static let exampleHeaderNib = "DozeDetailTypeHeader"
    }
    
    case amount, example
    
    var headerHeight: CGFloat {
        switch self {
        case .amount:
            // :UNITS_VISIBILITY: Handle imperial|metric unit button visibility
            let shouldShowTypeToggle = UserDefaults.standard.bool(forKey: SettingsKeys.unitsTypeToggleShowPref)
            if shouldShowTypeToggle {
                return 75 // Height: "Serving Sizes" + "Units"
            } else {
                return 50 // Height: "Serving Sizes" only
            }
        case .example:
            return 50
        }
    }
    
    var estimatedRowHeight: CGFloat {
        switch self {
        case .amount:
            return 75
        case .example:
            return 75
        }
    }
    
    var headerView: UIView? {
        switch self {
        case .amount:
            // :UNITS_VISIBILITY: Handle imperial|metric unit button visibility
            let shouldShowTypeToggle = UserDefaults.standard.bool(forKey: SettingsKeys.unitsTypeToggleShowPref)
            if shouldShowTypeToggle == false {
                if let v = Bundle.main.loadNibNamed(Nibs.amountHeaderNib, owner: nil)?.first as? UIView,
                   let label = v.viewWithTag(83105122) as? UILabel {
                    label.text = NSLocalizedString("doze_detail_section_sizes", comment: "Servings Sizes")
                    label.accessibilityIdentifier = "doze_detail_section_sizes_access"
                    return v
                }
                return nil
            }
            if let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
               let currentUnitsType = UnitsType(rawValue: unitsTypePrefStr),
               let uiView: UIView = Bundle.main.loadNibNamed(Nibs.amountHeaderUnitNib, owner: nil)?.first as? UIView,
               let labelSection = uiView.viewWithTag(83105122) as? UILabel,
               let labelUnits = uiView.viewWithTag(85110105) as? UILabel {
                
                labelSection.text = NSLocalizedString("doze_detail_section_sizes", comment: "Servings Sizes")
                labelSection.accessibilityIdentifier = "doze_detail_section_sizes_access"
                labelUnits.text = NSLocalizedString("units_label", comment: "Units:")
                
                // Handle imperial vs. metric units
                let buttons = uiView.subviews(ofType: UIButton.self)
                for btn in buttons {
                    btn.setTitle(currentUnitsType.title, for: .normal)
                }              
                return uiView
            }
            return nil
        case .example:
            if let uiView = Bundle.main.loadNibNamed(Nibs.exampleHeaderNib, owner: nil)?.first as? UIView {
                if let label = uiView.viewWithTag(84121112) as? UILabel {
                    label.text = NSLocalizedString("doze_detail_section_types", comment: "Types")
                    label.accessibilityIdentifier = "doze_detail_section_types_access"
                    return uiView
                }
            }
            return nil
        }
    }
    
}
