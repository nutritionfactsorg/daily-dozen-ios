//
//  HealthWeightRecord.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
import SwiftUI
import HealthKit

struct HealthWeightRecord: Sendable {
    let ampm: DataWeightType
    var hkWeightSamples: [HKQuantitySample]

    func getWeightToShow() -> (time: String, kg: Double) {
        guard let sample = hkWeightSamples.first else { return ("", 0.0) }
        let timeHHmm = sample.startDate.datestampHHmm
        let kg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
        return (time: timeHHmm, kg: kg)
    }
}
