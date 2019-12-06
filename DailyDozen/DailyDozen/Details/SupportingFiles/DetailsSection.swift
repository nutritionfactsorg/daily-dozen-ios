//
//  SectionType.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 01.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum DetailsSection: Int {
    
    private struct Nibs {
        static let sizesHeaderNib = "SizesHeader"
        static let typesHeaderNib = "TypesHeader"
        static let sizesTweaksHeaderNib = "SizesTweaksHeader"
        static let typesTweaksHeaderNib = "TypesTweaksHeader"
    }
    
//    private struct Strings {
//        static let sizesHeaderTitle = "Serving Sizes"
//        static let typesHeaderTitle = "Types"
//    }
    
    case sizes, types
    
    var rowHeight: CGFloat {
        switch self {
        case .sizes:
            return 75
        case .types:
            return 75
        }
    }
    
    var headerHeight: CGFloat {
        switch self {
        case .sizes:
            return 75
        case .types:
            return 50
        }
    }
    
    //var headerTweaksHeight: CGFloat {
    //    switch self {
    //    case .sizes:
    //        return 75
    //    case .types:
    //        return 50
    //    }
    //}
    
    var headerView: UIView? {
        switch self {
        case .sizes:
            // Handle imperial vs. metric units
            if let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
                let currentUnitsType = UnitsType(rawValue: unitsTypePrefStr),
                let uiView: UIView = Bundle.main
                    .loadNibNamed(Nibs.sizesHeaderNib, owner: nil)?
                    .first as? UIView {
                for subview1 in uiView.subviews {
                    if let stackView1 = subview1 as? UIStackView {
                        for subview2 in stackView1.subviews {
                            if let stackView2 = subview2 as? UIStackView {
                                for subview3 in stackView2.subviews {
                                    if let button = subview3 as? UIButton {
                                        button.setTitle(currentUnitsType.title, for: .normal)
                                    }
                                }
                            }
                        }
                    }
                }
                return uiView
            }
            return nil
        case .types:
            return Bundle.main
                .loadNibNamed(Nibs.typesHeaderNib, owner: nil)?.first as? UIView
        }
    }
    
    var headerTweaksView: UIView? {
        switch self {
        case .sizes:
            // Handle imperial vs. metric units
            if let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
                let currentUnitsType = UnitsType(rawValue: unitsTypePrefStr),
                let uiView: UIView = Bundle.main
                    .loadNibNamed(Nibs.sizesTweaksHeaderNib, owner: nil)?
                    .first as? UIView {
                for subview1 in uiView.subviews {
                    if let stackView1 = subview1 as? UIStackView {
                        for subview2 in stackView1.subviews {
                            if let stackView2 = subview2 as? UIStackView {
                                for subview3 in stackView2.subviews {
                                    if let button = subview3 as? UIButton {
                                        button.setTitle(currentUnitsType.title, for: .normal)
                                    }
                                }
                            }
                        }
                    }
                }
                return uiView
            }
            return nil
        case .types:
            return Bundle.main
                .loadNibNamed(Nibs.typesTweaksHeaderNib, owner: nil)?.first as? UIView
        }
    }
    
//    var title: String? {
//        switch self {
//        case .sizes:
//            return Strings.sizesHeaderTitle
//        case .types:
//            return Strings.typesHeaderTitle
//        }
//    }
    
}
