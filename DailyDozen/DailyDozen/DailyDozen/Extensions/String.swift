//
//  String.swift
//  DailyDozen
//
//  Copyright © 2020-2025 NutritionFacts.org. All rights reserved.
//
//

import Foundation

extension String {
    /// Parses a string that may use either "." or "," as decimal separator into a Double.
    /// Returns nil if invalid or negative.
    func toWeightDouble() -> Double? {
        let cleaned = self.filter { !$0.isWhitespace }
        guard !cleaned.isEmpty else { return nil }
        
        // First try invariant (fast path for en_US etc.)
        if let value = Double(cleaned) {
            return value > 0 ? value : nil
        }
        
        // If that fails, replace comma with period and try again
        let commaReplaced = cleaned.replacingOccurrences(of: ",", with: ".")
        if let value = Double(commaReplaced) {
            return value > 0 ? value : nil
        }
        
        return nil
    }
}
