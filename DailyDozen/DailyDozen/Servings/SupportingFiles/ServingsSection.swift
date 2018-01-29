//
//  ServingsSection.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 15.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum ServingsSection: Int {

    private struct Keys {
        static let vitaminsHeader = "VitaminsHeader"
    }

    case main, vitamin

    private var vitaminsCount: Int {
        return 2
    }

    var rowHeight: CGFloat {
        return 120
    }

    var headerHeight: CGFloat {
        switch self {
        case .main:
            return 0.1
        case .vitamin:
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
        case .vitamin:
            return Bundle.main
                .loadNibNamed(Keys.vitaminsHeader, owner: nil)?.first as? UIView
        }
    }

    func numberOfRowsInSection(with count: Int) -> Int {
        switch self {
        case .main:
            return count - vitaminsCount
        case .vitamin:
            return vitaminsCount
        }
    }
}
