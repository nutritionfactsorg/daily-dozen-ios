//
//  HealthSynchronizer.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable function_body_length

import Foundation
import HealthKit
import RealmSwift

/// HealthSynchronizer coordinates data between the application database and healthkit.
///
/// Notes:
/// * HKQuantitySample does not provide access to data added to HealthKit.
/// * 
/// 
/// Tolerance Notes: 
/// * 0.10 kg  == 0.220 lbs
/// * 0.10 lbs == 0.045 kg
struct HealthSynchronizer {
    
    static var shared = HealthSynchronizer()
    
    // MARK: - Properties
    private let realm = RealmProvider.primary
    
    /// Note: keep `realm` operations on this thread. Pass value copies of realm objects to the `serialSyncQueue` tasks.
    private let serialSyncQueue = DispatchQueue(label: "com.nutritionfacts.queues.serial.sync", qos: DispatchQoS.userInitiated)
    
    public func resetSyncAll() {
        // Note: keep realm object access and processing on the same thread
        let dbResults = self.realm.getDBWeightDatetimes()
        var dbValues = [DataWeightValues]()
        for record: DataWeightRecord in dbResults {
            // Copy Realm `Object` values on this thead before completion block and `async` enqueueing.
            dbValues.append(DataWeightValues(record: record))
        }
        HealthManager.shared.deleteHKAllWeigths { // completion: () -> Void
            for values in dbValues {
                self.serialSyncQueue.async {
                    guard let datetime = values.datetime else { return }
                    let ampm = datetime.ampm
                    let kg = values.kg
                    self.syncWeightDateHK(date: datetime, ampm: ampm, kg: kg)
                }
            }
        }
    }
    
    /// Only modifies HealthKit sample values
    public func syncWeightDateHK(date: Date, ampm: DataWeightType, kg: Double) {
        let predicate = HealthManager.shared.buildPredicate(date: date, ampm: ampm)
        
        // AM: ascending order TRUE  so earliest AM time lists first.
        // PM: ascending order FALSE so latest   PM time lists first.
        let ascending = ampm == .am
        
        let values = DataWeightValues(date: date, weightType: ampm, kg: kg)
        
        serialSyncQueue.async {
            HealthManager.shared.readHKWeight(
                predicate: predicate, 
                ascending: ascending, 
                passthru: values,
                handler: self.syncWeightDateResultsHK)
        }
    }
    
    /// Only modifies HealthKit sample values
    private func syncWeightDateResultsHK(passthru: Any?, query: HKSampleQuery, samples: [HKSample]?, error: Error?) {
        if let error = error {
            LogService.shared.error("syncWeightDateResultsHK \"\(error.localizedDescription)\"")
        }
        
        guard let values = passthru as? DataWeightValues,
            let datetime = values.datetime else {
                LogService.shared.error("syncWeightDateResultsHK expected an 'VALUES' DataWeightType")
                return
        }
        
        // Case: no existing HK samples for this datetime. Save sample
        guard let samples = samples as? [HKQuantitySample] else {
            serialSyncQueue.async {
                HealthManager.shared.saveHKWeight(date: datetime, kg: values.kg)
            }
            return
        }
        
        // "HKTweak" HealthKit entries created by DailyDozen app
        // "HKOther" HealthKit entries created by non-DailyDozen apps. e.g. Apple's Health app 
        // search for matching samples
        let bundleId = Bundle.main.bundleIdentifier!
        var samplesHKTweak: [HKQuantitySample] = []
        var matchHKTweak: HKQuantitySample?
        var matchHKOther: HKQuantitySample?
        for item in samples {
            let bodymassKg = item.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            if item.sourceRevision.source.bundleIdentifier == bundleId {
                // :TDB: only checks kg value for the given AM/PM time period.
                // Perhaps also constrain match to a more narrow datetime range.
                if matchHKTweak == nil && abs(bodymassKg - values.kg) < 0.1 {
                    matchHKTweak = item
                } else {
                    samplesHKTweak.append(item)
                }
            } else {
                if matchHKOther == nil && abs(bodymassKg - values.kg) < 0.1 {
                    matchHKOther = item
                }
            }
        }
        
        // Case: matches an HKOther quantity. Remove any HKTweak values.
        if matchHKOther != nil {
            // Remove any HKTweak samples
            if let matchHKTweak = matchHKTweak {
                samplesHKTweak.append(matchHKTweak)
            }
            serialSyncQueue.async {
                HealthManager.shared.deleteHKWeight(samples: samplesHKTweak)
            }
            return
        }
        
        // Case: matches a HKTweak quantity. Remove extra, non-matching HKTweak values.
        if matchHKTweak != nil {
            // Remove any HKTweak samples other than the matched sample
            serialSyncQueue.async {
                HealthManager.shared.deleteHKWeight(samples: samplesHKTweak)
            }
            return
        }
        
        // Case: DB passthru value exists without any HealthKit match
        serialSyncQueue.async {
            // Remove any extra non-matching HKTweak samples
            HealthManager.shared.deleteHKWeight(samples: samplesHKTweak)
        }
        serialSyncQueue.async {
            // Add new HKTweak value
            HealthManager.shared.saveHKWeight(date: datetime, kg: values.kg)
        }
    }
    
    /// Updates both Realm and HealthKit values
    func syncWeightPut(date: Date, ampm: DataWeightType, kg: Double) {
        if let record = realm.getDBWeight(date: date, ampm: ampm) {
            if abs(record.kg - kg) < 0.1 {
                return // close enough. no additional actions needed.
            }
        }
        // Note: keep `realm` access on this thread.
        realm.saveDBWeight(date: date, ampm: ampm, kg: kg)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "NoticeChangedWeight"), object: date, userInfo: nil)
        
        serialSyncQueue.async {
            self.syncWeightDateHK(date: date, ampm: ampm, kg: kg)
        }
    }
    
    /// 
    func syncWeightToShow(date: Date, ampm: DataWeightType) -> (time: String, weight: String) {
        let record: DataWeightRecord? = realm.getDBWeight(date: date, ampm: ampm)
        
        // Return DB weight record if present
        if let record = record {
            let weightStr = SettingsManager.isImperial() ? record.lbsStr : record.kgStr
            return (time: record.timeAmPm, weight: weightStr)
        }
        
        // Otherwise, request "first" HK weight record if present
        serialSyncQueue.async {
            HealthManager.shared.readHKWeight(date: date, ampm: ampm)
        }
        // Return empty values. HK will update later via notification
        return (time: "", weight: "")
    }
        
    func syncWeightClear(date: Date, ampm: DataWeightType) {
        realm.deleteDBWeight(date: date, ampm: ampm)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "NoticeChangedWeight"), object: date, userInfo: nil)
        serialSyncQueue.async {
            HealthManager.shared.deleteHKWeight(date: date, ampm: ampm)
        }
    }
    
    func syncWeightExport(marker: String) {
        serialSyncQueue.async {
            HealthManager.shared.exportHKWeight(marker: marker)
        }
    }
    
}
