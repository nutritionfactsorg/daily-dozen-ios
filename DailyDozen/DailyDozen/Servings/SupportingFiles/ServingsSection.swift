//
//  ServingsSection.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 15.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum ServingsSection: Int {

    /// Set supplementsCount based `RealmConfigLegacy` `initialDoze(…)` items.
    /// See `RealmConfigLegacy` for details
    static let supplementsCount: Int = 1
    
    private struct Keys {
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
            return Bundle.main
                .loadNibNamed(Keys.supplementsHeader, owner: nil)?.first as? UIView
        }
    }

    func numberOfRowsInSection(with count: Int) -> Int {
        switch self {
        case .main:
            return count - ServingsSection.supplementsCount
        case .supplements:
            return ServingsSection.supplementsCount
        }
    }
}
