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
        static let sizesHeader = "SizesHeader"
        static let typesHeader = "TypesHeader"
    }

    private struct Strings {
        static let sizesHeader = "Serving Sizes"
        static let typesHeader = "Types"
    }

    case sizes, types

    var rowHeight: CGFloat {
        switch self {
        case .sizes, .types:
            return 75
        }
    }

    var headerHeigh: CGFloat {
        switch self {
        case .sizes:
            return 75
        case .types:
            return 50
        }
    }

    var headerView: UIView? {
        switch self {
        case .sizes:
            return Bundle.main
                .loadNibNamed(Nibs.sizesHeader, owner: nil)?.first as? UIView
        case .types:
            return Bundle.main
                .loadNibNamed(Nibs.typesHeader, owner: nil)?.first as? UIView
        }
    }

    var title: String? {
        switch self {
        case .sizes:
            return Strings.sizesHeader
        case .types:
            return Strings.typesHeader
        }
    }

}
