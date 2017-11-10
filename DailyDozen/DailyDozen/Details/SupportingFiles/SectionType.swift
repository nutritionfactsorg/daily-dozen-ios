//
//  SectionType.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 01.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum SectionType: Int {

    private struct Keys {
        static let sizesHeader = "SizesHeader"
        static let typesHeader = "TypesHeader"
    }

    case image, sizes, types

    var rowHeight: CGFloat {
        switch self {
        case .image:
            return 200
        case .sizes, .types:
            return 75
        }
    }

    var headerHeigh: CGFloat {
        switch self {
        case .image:
            return 1
        case .sizes:
            return 75
        case .types:
            return 50
        }
    }

    var headerView: UIView? {
        switch self {
        case .image:
            return nil
        case .sizes:
            return Bundle.main
                .loadNibNamed(Keys.sizesHeader, owner: nil)?.first as? UIView
        case .types:
            return Bundle.main
                .loadNibNamed(Keys.typesHeader, owner: nil)?.first as? UIView
        }
    }

    var title: String? {
        switch self {
        case .image:
            return nil
        case .sizes:
            return "Serving Sizes"
        case .types:
            return "Types"
        }
    }

}
