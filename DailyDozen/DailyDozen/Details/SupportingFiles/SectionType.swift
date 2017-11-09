//
//  SectionType.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 01.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum SectionType: Int {

    case image, sizes, types

    var height: CGFloat {
        switch self {
        case .image:
            return 200
        case .sizes, .types:
            return 75
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
