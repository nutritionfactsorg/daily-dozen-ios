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
    //TBDz
    func syncWeightPutWAS2(date: Date, ampm: DataWeightType, kg: Double, time: Date, tracker: SqlDailyTracker) async throws {
        print("•HK• syncWeightPut started for \(ampm.typeKey) on \(date.datestampSid): \(kg) kg at \(time.datestampHHmm)")
            //print("•HK• syncWeightPut started for \(ampm.typeKey) on \(date.datestampSid): \(String(format: "%.2f", kg)) kg at \(time.datestampyyyyMMddHHmmss)")
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
               // print("!!!••••updateMockDB(with: tracker)•••• ")
                // CREATE A COPY with only the updated field
                var updatedTracker = tracker
               // let weightRecord = SqlDataWeightRecord(date: date, weightType: ampm, kg: kg)
                let weightRecord = SqlDataWeightRecord(date: date, weightType: ampm, kg: kg, timeHHmm: time.datestampHHmm)
              
                    if ampm == .am {
                        updatedTracker.weightAM = weightRecord
                       // updatedTracker.weightAM?.dataweight_kg = kg
                       // updatedTracker.weightAM?.dataweight_time = time.datestampHHmm
                        updatedTracker.weightPM = nil  // CLEAR OTHER
                    } else {
                        //updatedTracker.weightPM?.dataweight_kg = kg
                        //updatedTracker.weightPM?.dataweight_time = time.datestampHHmm
                        updatedTracker.weightPM = weightRecord
                        updatedTracker.weightAM = nil  // CLEAR OTHER
                    }
                await SqlDailyTrackerViewModel.shared.updateDatabase(with: updatedTracker)
                print("•HK• syncWeightPut updatedDatabase for \(ampm.typeKey)")
//                await MainActor.run {
//                    NotificationCenter.default.post(name: .init("NoticeChangedWeight"), object: date)
//                }
            } catch {
                print("•HK• syncWeightPut save failed: \(error.localizedDescription)")
                throw error
            }
        }
        
    func syncWeightClear(date: Date, ampm: DataWeightType) async throws {
        print("•HK• syncWeightClear for \(ampm.typeKey) on \(date.datestampSid)")
            try await HealthManager.shared.deleteHKWeight(date: date, ampm: ampm)
            print("•HK• syncWeightClear deleted HealthKit weight for \(ampm.typeKey)")

            // GET CURRENT TRACKER
            let currentTracker = await SqlDailyTrackerViewModel.shared.tracker(for: date)

            // CREATE COPY WITH WEIGHT CLEARED, COUNTS PRESERVED
            var clearedTracker = currentTracker
            if ampm == .am {
                clearedTracker.weightAM = nil
            } else {
                clearedTracker.weightPM = nil
            }

            await SqlDailyTrackerViewModel.shared.updateDatabase(with: clearedTracker)
    }
    
}
