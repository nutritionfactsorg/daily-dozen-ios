//
//  HealthSyncronizer.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
import SwiftUI
import HealthKit

//TBDz20250925    syncWeightPut and syncWeightClear has MockDB

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
                await MainActor.run {
                    NotificationCenter.default.post(name: .init("BodyMassDataAvailable"), object: record)
                }
                print("•HK• syncWeightToShow found HealthKit weight: \(weightStr)")
                return (time: time, weight: weightStr)
            }
        } catch {
            print("•HK• syncWeightToShow error: \(error.localizedDescription)")
        }
        print("•HK• syncWeightToShow returning empty")
        return ("", "")
    }
    
    func syncWeightPut(date: Date, ampm: DataWeightType, kg: Double, time: Date, tracker: SqlDailyTracker) async throws {
        print("•HK• syncWeightPut started for \(ampm.typeKey) on \(date.datestampSid): \(String(format: "%.2f", kg)) kg at \(time.datestampyyyyMMddHHmmss)")
        guard kg > 0 else {
            print("•HK• syncWeightPut skipped: invalid weight \(kg)")
            return
        }
        
        do {
            let samples = try await HealthManager.shared.readHKWeight(date: date, ampm: ampm)
            if !samples.isEmpty {
                print("•HK• Found \(samples.count) existing samples for \(ampm.typeKey)")
                try await HealthManager.shared.deleteHKWeight(date: date, ampm: ampm)
                print("•HK• Deleted \(samples.count) existing samples")
            }
        } catch {
            print("•HK• Error reading/deleting samples: \(error.localizedDescription)")
            throw error
        }
        
        do {
            try await HealthManager.shared.saveHKWeight(date: time, kg: kg)
            print("•HK• syncWeightPut saved successfully for \(ampm.typeKey)")
           print("!!!••••updateMockDB(with: tracker)•••• ")
            //updateMockDB(with: tracker) // Use global function
            print("•HK• syncWeightPut updated mockDB for \(ampm.typeKey)")
            await MainActor.run {
                NotificationCenter.default.post(name: .init("NoticeChangedWeight"), object: date)
            }
        } catch {
            print("•HK• syncWeightPut save failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func syncWeightClear(date: Date, ampm: DataWeightType, tracker: SqlDailyTracker) async throws {
        print("•HK• syncWeightClear for \(ampm.typeKey) on \(date.datestampSid)")
        try await HealthManager.shared.deleteHKWeight(date: date, ampm: ampm)
        print("•HK• syncWeightClear deleted HealthKit weight for \(ampm.typeKey)")
        //updateMockDB(with: tracker) // Use global function
        print ("•••••!!!!!HK• syncWeightClear updateMockDB!!!!!•••••")
        print("•HK• syncWeightClear updated mockDB for \(ampm.typeKey)")
        await MainActor.run {
            NotificationCenter.default.post(name: .init("NoticeChangedWeight"), object: date)
        }
    }
}
