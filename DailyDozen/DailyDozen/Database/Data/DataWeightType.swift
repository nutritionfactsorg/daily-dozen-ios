//
//  DataWeightType.swift
//  DatabaseMigration
//
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation

public enum DataWeightType: String {
    
    case am
    case pm
    
    init?(typeKey: String) {
        self = DataWeightType(rawValue: String(typeKey))!
    }
    
    init?(typeNid: String) {
        switch typeNid {
        case "0":
            self = .am
        case "1":
            self = .pm
        default:
            return nil
        }
    }
    
    init?(typeNid: Int) {
        switch typeNid {
        case 0:
            self = .am
        case 1:
            self = .pm
        default:
            return nil
        }
    }
    
    var typeKey: String {
        return self.rawValue
    }
    
    var typeNid: Int {
        switch self {
        case .am:
            return 0
        case .pm:
            return 1
        }
    }
}
