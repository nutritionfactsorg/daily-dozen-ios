//
//  ServingsSection.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum ServingsSection: Int {

    static let supplementsCount: Int = 1
    
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
            return Bundle.main
                .loadNibNamed(Strings.supplementsHeader, owner: nil)?.first as? UIView
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
