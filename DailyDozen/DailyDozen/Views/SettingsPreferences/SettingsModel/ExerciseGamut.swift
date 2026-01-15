//
//  ExerciseGamut.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import Foundation

public enum ExerciseGamut: Int {
    /// one 40-45 minute exercise session
    case one = 1
    /// three 15-minute sessions
    case three = 3
    /// size 7-8 minute sessions
    case six = 6
    
    init?(_ i: Int) {
        switch i {
        case 1: self = .one
        case 3: self = .three
        case 6: self = .six
        default: return nil
        }
    }
    
    init?(_ str: String) {
        guard let i = Int(str)
        else { return nil }
        self.init(i)
    }
    
    /// Defaults to legacy gamut
    static var `default`: ExerciseGamut {
        return .one
    }
    
    var int: Int {
        self.rawValue
    }
}
