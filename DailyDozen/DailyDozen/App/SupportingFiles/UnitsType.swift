//
//  UnitsType.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 13.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation

enum UnitsType: String {

    case imperial
    case metric

    /// Returns an uppercase version of the rawValue for the current type.
    var title: String {
        switch self {
        case .imperial:
            return "IMPERIAL" // :NYI:ToBeLocalized:
        case .metric:
            return "METRIC" // :NYI:ToBeLocalized:
        }
    }
    
    /// Returns toggled type for the current type.
    var toggledType: UnitsType {
        return self == .metric ? UnitsType.imperial : UnitsType.metric
    }
}
