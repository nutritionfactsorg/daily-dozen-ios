//
//  UnitsType.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 13.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation

enum UnitsType: String {

    case metric, imperial

    /// Returns an uppercase version of the rawValue for the current type.
    var title: String {
        return self.rawValue.uppercased()
    }

    /// Returns toggled type for the current type.
    var toggledType: UnitsType {
        return self == .metric ? UnitsType.imperial : UnitsType.metric
    }
}
