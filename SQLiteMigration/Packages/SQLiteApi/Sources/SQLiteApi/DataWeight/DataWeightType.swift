//
//  DataWeightType.swift
//  SQLiteApi
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
