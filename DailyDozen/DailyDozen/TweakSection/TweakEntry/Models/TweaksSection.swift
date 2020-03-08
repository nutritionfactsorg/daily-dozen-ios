//
//  TweaksSection.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum TweaksSection: Int {
    
    case main

    var rowHeight: CGFloat {
        return 100
    }

    var headerHeight: CGFloat {
        switch self {
        case .main:
            return 0.1
        }
    }

    var footerHeight: CGFloat {
        return 0.1
    }

    var headerView: UIView? {
        switch self {
        case .main:
            return nil
        }
    }

    func numberOfRowsInSection(with count: Int) -> Int {
        switch self {
        case .main:
            return count
        }
    }
}
