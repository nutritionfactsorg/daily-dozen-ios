//
//  TweaksSection.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum TweaksSection: Int {

    /// Set supplementsCount based `RealmConfigLegacy` `initialDoze(…)` items.
    /// See `RealmConfigLegacy` for details
    static let supplementsCount: Int = 0
    
    private struct Strings {
        static let supplementsHeader = "SupplementsHeader"
    }

    case main, supplements

    var rowHeight: CGFloat {
        return 100
    }

    var headerHeight: CGFloat {
        switch self {
        case .main:
            return 0.1
        case .supplements:
            return 50
        }
    }

    var footerHeight: CGFloat {
        return 0.1
    }

    var headerView: UIView? {
        switch self {
        case .main:
            return nil
        case .supplements:
            //return Bundle.main
            //    .loadNibNamed(Strings.supplementsHeader, owner: nil)?.first as? UIView
            return nil
        }
    }

    func numberOfRowsInSection(with count: Int) -> Int {
        switch self {
        case .main:
            return count - TweaksSection.supplementsCount
        case .supplements:
            return TweaksSection.supplementsCount
        }
    }
}
