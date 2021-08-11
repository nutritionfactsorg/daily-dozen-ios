//
//  HealthManager.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation
import HealthKit

// If the user denied the authorization request, 
// HealthKit only provides information written by the app and nothing else.
// https://developer.apple.com/documentation/HealthKit/HKAuthorizationStatus 

// HKQuantityType > HKSampleType > HKObjectType

/// HealthManager provides read, save, delete layer for HealthKit.
class HealthManager {
    
    public static let shared = HealthManager()
    
    public let hkHealthStore = HKHealthStore()
    
    public func isAuthorized() -> Bool {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        if let bodymassQType = HKQuantityType.quantityType(forIdentifier: .bodyMass) {
            let healthStore = HKHealthStore()
            let authorizationStatus = healthStore.authorizationStatus(for: bodymassQType)
            
            switch authorizationStatus {
            case HKAuthorizationStatus.sharingAuthorized: return true
            case .sharingDenied: return false
            default: return false
            }
        }
        return false
    }
    
    public func requestPermissions() {
        let hkTypesToRead: Set<HKSampleType> = [
            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
        ]
        
        let hkTypesToWrite: Set<HKSampleType> = [
            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
        ]
        
        hkHealthStore.requestAuthorization(
            toShare: hkTypesToWrite, 
            read: hkTypesToRead, 
            completion: { (success, error) in
                if success {
                    LogService.shared.debug("•HK• HealthManager Authorization success")
                } else {
                    LogService.shared.error("•HK• HealthManager Authorization error: \(String(describing: error?.localizedDescription))")
                }
        })
    }
    
    public func buildPredicate(date: Date, ampm: DataWeightType) -> NSPredicate {
        let baseDate = Calendar.current.startOfDay(for: date)
        var dateComponentsStart = DateComponents()
        dateComponentsStart.hour = ampm == .am ? 0 : 12
        let startDate = Calendar.current.date(byAdding: dateComponentsStart, to: baseDate)!
        var dateComponentsEnd = DateComponents()
        dateComponentsEnd.hour = ampm == .am ? 12 : 24
        let endDate = Calendar.current.date(byAdding: dateComponentsEnd, to: baseDate)!
        
        // Weight sample "start" time .greater.than.or.equal.to. query target start time, and
        // weight sample "end" time .less.than. query target end time.
        let options: HKQueryOptions = [.strictStartDate]
        
        let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: options)
        return predicate
    }
    
    public func buildPredicate(fromDate: Date, thruDate: Date) -> NSPredicate {
        let dateIn = Calendar.current.startOfDay(for: fromDate)
        var dateComponentsStart = DateComponents()
        dateComponentsStart.hour = 0
        let startDate = Calendar.current.date(byAdding: dateComponentsStart, to: dateIn)!
        
        let baseOut = Calendar.current.startOfDay(for: thruDate)
        var dateComponentsEnd = DateComponents()
        dateComponentsEnd.hour = 24
        let endDate = Calendar.current.date(byAdding: dateComponentsEnd, to: baseOut)!
        
        // Weight sample "start" time .greater.than.or.equal.to. query target start time, and
        // weight sample "end" time .less.than. query target end time.
        let options: HKQueryOptions = [.strictStartDate]
        
        let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: options)
        return predicate
    }
    
    // MARK: - READ
    
    /// Read HealthKit data and send update notification.
    public func readHKWeight(date: Date, ampm: DataWeightType) {
        LogService.shared.debug("•HK• WeightEntryViewController readHKWeight date: \(date.datestampyyyyMMddHHmmss) ampm: \(ampm.typeKey)")        
        let predicate = buildPredicate(date: date, ampm: ampm)
        
        // AM: ascending order TRUE  so earliest AM time lists first.
        // PM: ascending order FALSE so latest   PM time lists first.
        let ascending = ampm == .am 
        
        readHKWeight(predicate: predicate, ascending: ascending, passthru: ampm, handler: readResultsDisplay)
    }
    
    public func readHKWeight(key: String, values: [Any]? = nil) {
        let predicate: NSPredicate!
        if let values = values {
            predicate = HKQuery.predicateForObjects(withMetadataKey: key, allowedValues: values)
        } else {
            predicate = HKQuery.predicateForObjects(withMetadataKey: key)
        }
        
        readHKWeight(predicate: predicate, ascending: true, handler: readResultsLog)
    }
    
    // Possible additional predication:
    //   let p0: NSPredicate = HKQuery.predicateForSamples(...)
    //   let p1 = HKQuery.predicateForObjects(...)
    //   let p2 = NSCompoundPredicate(notPredicateWithSubpredicate: p1)
    //   let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p0, p1])
    
    public func readHKWeight(
        predicate: NSPredicate?, 
        ascending: Bool, 
        passthru: Any? = nil,
        handler: @escaping (Any?, HKSampleQuery, [HKSample]?, Error?) -> Void) {
        
        let bodymassQType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: ascending)
                
        let sampleQuery = HKSampleQuery(
            sampleType: bodymassQType,        // HKSampleType
            predicate: predicate,             // NSPredicate?
            limit: HKObjectQueryNoLimit,      // Int
            sortDescriptors: [sortDescriptor] // [NSSortDescriptor]?
        ) { (query: HKSampleQuery, samples: [HKSample]?, error: Error?) in
            handler(passthru, query, samples, error)
        }
        
        self.hkHealthStore.execute(sampleQuery as HKSampleQuery)
    }
    
    private func readResultsDisplay(passthru: Any?, query: HKSampleQuery, samples: [HKSample]?, error: Error?) {
        
        if let error = error {
            LogService.shared.error("readHKResultDisplay \"\(error.localizedDescription)\"")
        }
        
        guard let ampm = passthru as? DataWeightType else {
            LogService.shared.error("readHKResultDisplay expected an 'AMPM' value")
            return
        }
        
        if let hkQuantitySamples = samples as? [HKQuantitySample] {
            let r = HealthWeightRecord(ampm: ampm, hkWeightSamples: hkQuantitySamples)
            LogService.shared.debug("•HK• WeightEntryViewController HealthWeightRecord\n\(r.toString())")
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(
                    name: Notification.Name(rawValue: "BodyMassDataAvailable"),
                    object: r,
                    userInfo: nil)
                LogService.shared.debug("•HK• WeightEntryViewController post BodyMassDataAvailable")
            })
        }               
    }
    
    private func readResultsLog(passthru: Any?, query: HKSampleQuery, samples: [HKSample]?, error: Error?) {
        guard let samples = samples as? [HKQuantitySample] else {
            LogService.shared.info("readResultsLog no samples found")
            return 
        }
        
        var str = "\nHealthManager READ Results:\n"
        str.append(HealthManager.toStringCSV(samples: samples))
        LogService.shared.info(str)
    }
    
    // MARK: - SAVE
    
    public func saveHKWeight(date: Date, weight: Double) {
        saveHKWeight(date: date, weight: weight, isImperial: SettingsManager.isImperial())
    }
    
    public func saveHKWeight(date: Date, kg: Double) {
        saveHKWeight(date: date, weight: kg, isImperial: false)
    }
    
    /// Update or create HealthKit weight sample
    public func saveHKWeight(date: Date, weight: Double, isImperial: Bool, metadata: [String: Any]? = nil) {
        LogService.shared.verbose("::: HealthManager saveHKWeight \(String(format: "%.1f", weight)) \(date.datestampyyyyMMddHHmmss)")
        let bodymassQType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let hkUnit = isImperial ? HKUnit.pound() : HKUnit.gramUnit(with: .kilo)
        let hkQuantity = HKQuantity(unit: hkUnit, doubleValue: weight)
        
        let bodymassSample = HKQuantitySample(
            type: bodymassQType,  // HKQuantityType
            quantity: hkQuantity, // HKQuantity
            start: date,          // Date
            end: date,            // Date
            device: nil,          // HKDevice?
            metadata: metadata)   // [String: Any]?
        
        hkHealthStore.save(bodymassSample, withCompletion: saveResultsLog)
    }
    
    private func saveResultsLog(success: Bool, error: Error?) {
        if error != nil {
            LogService.shared.error("::: HealthManager saveResultsLog error: '\(error.debugDescription)'")
        }
        if success {
            LogService.shared.debug("::: HealthManager saveResultsLog SUCCESS")
        }
    }
    
    // MARK: - DELETE
    
    /// Clear all weight samples for which DailyDozen app is the source.
    /// Use: clear button
    public func deleteHKWeight(date: Date, ampm: DataWeightType) {
        let baseDate = Calendar.current.startOfDay(for: date)
        var dateComponentsStart = DateComponents()
        dateComponentsStart.hour = ampm == .am ? 0 : 12
        let startDate = Calendar.current.date(byAdding: dateComponentsStart, to: baseDate)!
        var dateComponentsEnd = DateComponents()
        dateComponentsEnd.hour = ampm == .am ? 12 : 24
        let endDate = Calendar.current.date(byAdding: dateComponentsEnd, to: baseDate)!
        
        // Weight sample "start" time .greater.than.or.equal.to. query target start time, and
        // weight sample "end" time .less.than. query target end time.
        let options: HKQueryOptions = [.strictStartDate]
        
        let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: options)
        
        deleteHKWeight(predicate: predicate, handler: deleteResultsLog)
    }
    
    // Use: remove "BIT" values
    public func deleteHKWeight(key: String, values: [Any]? = nil) {
        let predicate: NSPredicate!
        if let values = values {
            predicate = HKQuery.predicateForObjects(withMetadataKey: key, allowedValues: values)
        } else {
            predicate = HKQuery.predicateForObjects(withMetadataKey: key)
        }
        
        deleteHKWeight(predicate: predicate, handler: deleteResultsLog)
    }
    
    public func deleteHKWeight(samples: [HKObject]) {
        if samples.isEmpty == false {
            hkHealthStore.delete(samples, withCompletion: deleteResultsLog)            
        }
    }
        
    private func deleteHKWeight(predicate: NSPredicate, handler: @escaping (Bool, Int, Error?) -> Void) {
        let bodymassQType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        hkHealthStore.deleteObjects(of: bodymassQType, predicate: predicate, withCompletion: handler)
    }
    
    private func deleteResultsLog(success: Bool, deletedObjectCount: Int, error: Error?) {
        LogService.shared.info("HealthManager deleteResultsLog() success=\(success) count=\(deletedObjectCount) error=\(error.debugDescription)")
    }
    
    private func deleteResultsLog(success: Bool, error: Error?) {
        LogService.shared.info("HealthManager deleteResultsLog() success=\(success) error=\(error.debugDescription)")
    }
    
    // Use: clear & reset sync values
    public func deleteHKAllWeigths(completion: @escaping () -> Void) {
        let bodymassQType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let dailydozenHKSource = HKSource.default()
        let predicate = HKSampleQuery.predicateForObjects(from: dailydozenHKSource)
        
        hkHealthStore.deleteObjects(of: bodymassQType, predicate: predicate) { 
            (success: Bool, deletedObjectCount: Int, error: Error?) in
            if success == false {
                if let error = error {
                    LogService.shared.debug("deleteHKAllWeigths failed count=\(deletedObjectCount) error=\(error)")
                } else {
                    LogService.shared.debug("deleteHKAllWeigths failed count=\(deletedObjectCount)")
                }
                return
            }
            completion()
        }
    }
    
    // MARK: - Export
    
    public func exportHKWeight(marker: String) {
        let filename = "\(Date.datestampNow())_\(marker).csv"
        readHKWeight(predicate: nil, ascending: true, passthru: filename, handler: exportResults)
    }
    
    private func exportResults(passthru: Any?, query: HKSampleQuery, samples: [HKSample]?, error: Error?) {
        if let error = error {
            LogService.shared.error("HealthManager exportResults error:'\(error)'")
            return
        }
        
        guard let samples = samples as? [HKQuantitySample] else { 
            LogService.shared.verbose("HealthManager exportResults no weight samples found.")
            return 
        }
        
        guard let filename = passthru as? String else {
            LogService.shared.error("HealthManager exportResults passthru failed.")
            return
        }
        
        let outUrl = URL.inDocuments().appendingPathComponent(filename)
        let content = HealthManager.toStringCSV(samples: samples)
        do {
            try content.write(to: outUrl, atomically: true, encoding: .utf8)
        } catch {
            LogService.shared.error(
                "FAIL HealthManager exportResults \(error) path:'\(outUrl.path)'"
            )
        }
    }
        
    public static func toStringCSV(samples: [HKQuantitySample]) -> String {
        var str = "HK_PID,time,kg,lbs,source\n"
        
        for item: HKQuantitySample in samples {
            let bodymassKg = item.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            
            guard
                let weightKgStr = UnitsUtility.regionalKgWeight(fromKg: bodymassKg, toDecimalDigits: 2),
                let weightLbsStr = UnitsUtility.regionalLbsWeight(fromKg: bodymassKg, toDecimalDigits: 2)
            else {
                continue
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd.a"
            let dateStr = dateFormatter.string(from: item.startDate).lowercased()
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeStr = timeFormatter.string(from: item.startDate)
            
            let source = item.sourceRevision.source.bundleIdentifier
            
            str.append("\(dateStr),\(timeStr),\(weightKgStr),\(weightLbsStr),\(source)\n")
        }
        return str
    }
    
}
