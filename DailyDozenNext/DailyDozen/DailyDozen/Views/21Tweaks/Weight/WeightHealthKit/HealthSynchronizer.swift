//
//  HealthSyncronizer.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
import SwiftUI
import HealthKit

struct HealthSynchronizer {
    static var shared = HealthSynchronizer()
    // Remove serialSyncQueue; async/await handles concurrency
    // private let serialSyncQueue = DispatchQueue(label: "com.nutritionfacts.queues.serial.sync", qos: .userInitiated)

    func resetSyncAll() async throws {
        print("•HK• resetSyncAll started")
        // Delete all HealthKit weights
        try await HealthManager.shared.deleteHKAllWeights()
        print("•HK• Deleted all HealthKit weights")

        // Sync all mockDB weights to HealthKit
        for tracker in mockDB {
            if tracker.weightAM.dataweight_kg > 0, let time = Date(datestampHHmm: tracker.weightAM.dataweight_time, referenceDate: tracker.date) {
                print("•HK• Syncing AM weight for \(tracker.date.datestampSid): \(tracker.weightAM.dataweight_kg) kg")
                try await syncWeightPut(date: tracker.date, ampm: .am, kg: tracker.weightAM.dataweight_kg, time: time)
            }
            if tracker.weightPM.dataweight_kg > 0, let time = Date(datestampHHmm: tracker.weightPM.dataweight_time, referenceDate: tracker.date) {
                print("•HK• Syncing PM weight for \(tracker.date.datestampSid): \(tracker.weightPM.dataweight_kg) kg")
                try await syncWeightPut(date: tracker.date, ampm: .pm, kg: tracker.weightPM.dataweight_kg, time: time)
            }
        }
        print("•HK• resetSyncAll completed")
    }

    // TBDz Is this called now
    private func syncWeightDateHK(date: Date, ampm: DataWeightType, kg: Double) async throws {
        print("•HK• syncWeightDateHK for \(ampm.typeKey) on \(date.datestampSid): \(String(format: "%.2f", kg)) kg")
        guard kg > 0 else {
            print("•HK• syncWeightDateHK skipped: invalid weight \(kg)")
            return
        }

        do {
            let samples = try await HealthManager.shared.readHKWeight(date: date, ampm: ampm)
            if !samples.isEmpty {
                print("•HK• Found \(samples.count) existing samples for \(ampm.typeKey)")
                try await HealthManager.shared.deleteHKWeight(date: date, ampm: ampm)
                print("•HK• Deleted \(samples.count) existing samples")
            } else {
                print("•HK• No existing samples for \(ampm.typeKey)")
            }
        } catch {
            print("•HK• Error reading/deleting samples: \(error.localizedDescription)")
            throw error
        }

        // Save new weight
        do {
            try await HealthManager.shared.saveHKWeight(date: date, kg: kg)
            print("•HK• syncWeightDateHK saved successfully for \(ampm.typeKey)")
        } catch {
            print("•HK• syncWeightDateHK save failed: \(error.localizedDescription)")
            throw error
        }
    }

    func syncWeightPut(date: Date, ampm: DataWeightType, kg: Double, time: Date) async throws {
        print("•HK• syncWeightPut started for \(ampm.typeKey) on \(date.datestampSid): \(String(format: "%.2f", kg)) kg at \(time.datestampyyyyMMddHHmmss)")
        guard kg > 0 else {
            print("•HK• syncWeightPut skipped: invalid weight \(kg)")
            return
        }

        // Delete existing samples for this AM/PM slot
        do {
            let samples = try await HealthManager.shared.readHKWeight(date: date, ampm: ampm)
            if !samples.isEmpty {
                print("•HK• Found \(samples.count) existing samples for \(ampm.typeKey)")
                try await HealthManager.shared.deleteHKWeight(date: date, ampm: ampm)
                print("•HK• Deleted \(samples.count) existing samples")
            } else {
                print("•HK• No existing samples for \(ampm.typeKey)")
            }
        } catch {
            print("•HK• Error reading/deleting samples: \(error.localizedDescription)")
            throw error
        }

        // Save new weight
        do {
            try await HealthManager.shared.saveHKWeight(date: time, kg: kg)
            print("•HK• syncWeightPut saved successfully for \(ampm.typeKey)")
        } catch {
            print("•HK• syncWeightPut save failed: \(error.localizedDescription)")
            throw error
        }

        // Update mockDB
        let viewModel = WeightEntryViewModel()
        var tracker = viewModel.tracker(for: date)
        let weightRecord = SqlDataWeightRecord(date: date, weightType: ampm, kg: kg, timeHHmm: time.datestampHHmm)
        if ampm == .am {
            tracker.weightAM = weightRecord
        } else {
            tracker.weightPM = weightRecord
        }
        updateMockDB(with: tracker)
        print("•HK• Updated mockDB for \(ampm.typeKey): \(kg) kg")
        await MainActor.run {
            NotificationCenter.default.post(name: .init("NoticeChangedWeight"), object: date)
        }
    }

    func syncWeightToShow(date: Date, ampm: DataWeightType) async -> (time: String, weight: String) {
        print("•HK• syncWeightToShow for \(ampm.typeKey) on \(date.datestampSid)")
        let viewModel = WeightEntryViewModel()
        let tracker = viewModel.tracker(for: date)
        let weightRecord = ampm == .am ? tracker.weightAM : tracker.weightPM
        if weightRecord.dataweight_kg > 0 {
            let weightStr = UnitsUtility.regionalWeight(
                fromKg: weightRecord.dataweight_kg,
                toUnits: UnitsType(rawValue: UnitType.fromUserDefaults().rawValue) ?? .metric,
                toDecimalDigits: 1
            ) ?? ""
            print("•HK• syncWeightToShow found mockDB weight: \(weightStr)")
            return (time: weightRecord.dataweight_time, weight: weightStr)
        }

        // Fetch from HealthKit
        do {
            let samples = try await HealthManager.shared.readHKWeight(date: date, ampm: ampm)
            let record = HealthWeightRecord(ampm: ampm, hkWeightSamples: samples)
            let (time, kg) = record.getWeightToShow()
            if kg > 0 {
                let weightStr = UnitsUtility.regionalWeight(
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

    func syncWeightClear(date: Date, ampm: DataWeightType) async throws {
        print("•HK• syncWeightClear for \(ampm.typeKey) on \(date.datestampSid)")
        // Delete from HealthKit
        try await HealthManager.shared.deleteHKWeight(date: date, ampm: ampm)
        print("•HK• syncWeightClear deleted HealthKit weight for \(ampm.typeKey)")

        // Delete from mockDB
        let viewModel = WeightEntryViewModel()
        var tracker = viewModel.tracker(for: date)
        if ampm == .am {
            tracker.weightAM = SqlDataWeightRecord(date: date, weightType: .am, kg: 0, timeHHmm: "")
        } else {
            tracker.weightPM = SqlDataWeightRecord(date: date, weightType: .pm, kg: 0, timeHHmm: "")
        }
        updateMockDB(with: tracker)
        print("•HK• syncWeightClear updated mockDB for \(ampm.typeKey)")
        await MainActor.run {
            NotificationCenter.default.post(name: .init("NoticeChangedWeight"), object: date)
        }
    }

    // Helper to update mockDB (move from WeightEntryViewModel if needed)
//    private func updateMockDB(with tracker: SqlDailyTracker) {
//        let dateSid = tracker.date.datestampSid
//        if let index = mockDB.firstIndex(where: { $0.date.datestampSid == dateSid }) {
//            mockDB[index] = tracker
//        } else {
//            mockDB.append(tracker)
//        }
//        print("•mockDB• Updated: \(mockDB.map { ($0.date.datestampSid, $0.weightAM.dataweight_kg, $0.weightPM.dataweight_kg) })")
//    }
}
