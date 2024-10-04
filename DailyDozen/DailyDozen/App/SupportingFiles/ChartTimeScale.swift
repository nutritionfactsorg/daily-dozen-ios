//
//  ChartTimeScale.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import Foundation

// MARK: - Nested
enum ChartTimeScale: Int {
    case day, month, year
    
    func toString() -> String {
        switch self {
        case .day:
            return "day"
        case .month:
            return "day"
        case .year:
            return "year"
        }
    }
}
