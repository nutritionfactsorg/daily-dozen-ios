//
//  HealthSyncronizer.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
import SwiftUI
import HealthKit

struct HealthSynchronizer {
    static let shared = HealthSynchronizer()
    
    func syncWeightToShow(date: Date, ampm: DataWeightType) async -> (time: String, weight: String) {
        print("•HK• syncWeightToShow for \(ampm.typeKey) on \(date.datestampSid)")
        
        do {
            let samples = try await HealthManager.shared.readHKWeight(date: date, ampm: ampm)
            let record = HealthWeightRecord(ampm: ampm, hkWeightSamples: samples)
            let (time, kg) = record.getWeightToShow()
            if kg > 0 {
                let weightStr = await UnitsUtility.regionalWeight(
                    fromKg: kg,
                    toUnits: UnitsType(rawValue: UnitType.fromUserDefaults().rawValue) ?? .metric,
                    toDecimalDigits: 1
                ) ?? ""
                //                await MainActor.run {
                //                    NotificationCenter.default.post(name: .init("BodyMassDataAvailable"), object: record)
                //  }
                print("•HK• syncWeightToShow found HealthKit weight: \(weightStr)")
                print("•HK• Raw kg from HK: \(kg), unitType: \(UnitType.fromUserDefaults().rawValue), converted: \(weightStr)")
                return (time: time, weight: weightStr)
            }
        } catch {
            print("•HK• syncWeightToShow error: \(error.localizedDescription)")
        }
        print("•HK• syncWeightToShow returning empty")
        return ("", "")
    }
    
    func syncWeightPut(date: Date, ampm: DataWeightType, kg: Double, time: Date, tracker: SqlDailyTracker) async throws {
        try await HealthManager.shared.saveHKWeight(date: time, kg: kg)
    }
    
    func syncWeightClear(date: Date, ampm: DataWeightType) async throws {
        print("•HK• syncWeightClear for \(ampm.typeKey) on \(date.datestampSid)")
        try await HealthManager.shared.deleteHKWeight(date: date, ampm: ampm)
        print("•HK• syncWeightClear deleted HealthKit weight for \(ampm.typeKey)")
        
    }
    
}
