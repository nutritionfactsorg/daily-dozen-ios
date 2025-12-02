//
//  HealthManager.swift
//  DailyDozen
//
//  
//

import Foundation
import HealthKit

@MainActor
class HealthManager {
    static let shared = HealthManager()
    let hkHealthStore = HKHealthStore()

    func isAuthorized() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("•HK• HealthKit not available")
            return false
        }
        let bodyMassType = HKQuantityType(.bodyMass)
        let status = hkHealthStore.authorizationStatus(for: bodyMassType)
        return status == .sharingAuthorized
    }

    func requestPermissions() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "HealthKit unavailable"])
        }
        let types = Set([HKQuantityType(.bodyMass)])
        try await hkHealthStore.requestAuthorization(toShare: types, read: types)
        print("•HK• Authorization success")
    }

    func buildPredicate(date: Date, ampm: DataWeightType) -> NSPredicate {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: date)
        let startHour = ampm == .am ? 0 : 12
        let endHour = ampm == .am ? 12 : 24
        let startDate = calendar.date(byAdding: .hour, value: startHour, to: baseDate)!
        let endDate = calendar.date(byAdding: .hour, value: endHour, to: baseDate)!
        return HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate])
    }

    func readHKWeight(date: Date, ampm: DataWeightType) async throws -> [HKQuantitySample] {
        print("•HK• readHKWeight date: \(date.datestampyyyyMMddHHmmss) ampm: \(ampm.typeKey)")
        let predicate = buildPredicate(date: date, ampm: ampm)
        let ascending = ampm == .am
        let bodyMassType = HKQuantityType(.bodyMass)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: ascending)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: bodyMassType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("•HK• readHKWeight error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: (samples as? [HKQuantitySample]) ?? [])
            }
            hkHealthStore.execute(query)
        }
    }

//    func saveHKWeight(date: Date, kg: Double) async throws {
//        print("•HK• saveHKWeight \(String(format: "%.1f", kg)) kg at \(date.datestampyyyyMMddHHmmss)")
//        let bodyMassType = HKQuantityType(.bodyMass)
//        let quantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: kg)
//        let sample = HKQuantitySample(
//            type: bodyMassType,
//            quantity: quantity,
//            start: date,
//            end: date,
//            metadata: [HKMetadataKeyWasUserEntered: true, "AppSource": Bundle.main.bundleIdentifier ?? "DailyDozen"]
//        )
//        try await hkHealthStore.save(sample)
//        print("•HK• saveHKWeight success")
//    }
    func saveHKWeight(date: Date, kg: Double) async throws {
        print("•HK• Attempting to save \(String(format: "%.2f", kg)) kg at \(date.datestampyyyyMMddHHmmss)")
        guard kg > 0 else {
            print("•HK• Invalid weight: \(kg) kg, skipping save")
            throw NSError(domain: "HealthKit", code: -2, userInfo: [NSLocalizedDescriptionKey: "Weight must be positive"])
        }
        let bodyMassType = HKQuantityType(.bodyMass)
        let quantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: kg)
        let sample = HKQuantitySample(
            type: bodyMassType,
            quantity: quantity,
            start: date,
            end: date,
            metadata: [HKMetadataKeyWasUserEntered: true, "AppSource": Bundle.main.bundleIdentifier ?? "DailyDozen"]
        )
        do {
            try await hkHealthStore.save(sample)
            print("•HK• saveHKWeight success for \(String(format: "%.2f", kg)) kg at \(date.datestampyyyyMMddHHmmss)")
        } catch {
            print("•HK• saveHKWeight failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteHKWeight(date: Date, ampm: DataWeightType) async throws {
            let predicate = buildPredicate(date: date, ampm: ampm)
            let bodyMassType = HKQuantityType(.bodyMass)
            let deletedCount = try await hkHealthStore.deleteObjects(of: bodyMassType, predicate: predicate)
            print("•HK• deleteHKWeight deleted \(deletedCount) samples")
        }

    func deleteHKAllWeights() async throws {
            let bodyMassType = HKQuantityType(.bodyMass)
            let predicate = HKSampleQuery.predicateForObjects(from: .default())
            let deletedCount = try await hkHealthStore.deleteObjects(of: bodyMassType, predicate: predicate)
            print("•HK• deleteHKAllWeights deleted \(deletedCount) samples")
        }
}
