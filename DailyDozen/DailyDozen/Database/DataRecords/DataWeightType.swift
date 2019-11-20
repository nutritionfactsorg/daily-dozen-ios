//
//  DataWeightType.swift
//  DatabaseMigration
//
//  Created by marc on 2019.11.08.
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation

enum DataWeightType: String {
    
    case am
    case pm
    
    init?(typeKey: String) {
        if typeKey.hasSuffix("Key") {
            self = DataWeightType(rawValue: String(typeKey.dropLast(3)))!
        }
        return nil
    }
    
    func typeKey() -> String {
        return self.rawValue + "Key"
    }

}
