//
//  DataWeightType.swift
//  DatabaseMigration
//
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation

enum DataWeightType: String {
    
    case am
    case pm
    
    init?(typeKey: String) {
        self = DataWeightType(rawValue: String(typeKey))!
    }
    
    var typeKey: String {
        return self.rawValue
    }
}
