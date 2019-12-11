//
//  HealthManager.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation
import HealthKit

// If the user denied the authorization request, HealthKit only provides information written by the app and nothing else.
// https://developer.apple.com/documentation/healthkit/hkauthorizationstatus HKAuthorizationStatus

class HealthManager {
    
    public static let shared = HealthManager()
    
    public let healthStore = HKHealthStore()
    
    public func isAuthorized() -> Bool {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        if let type = HKObjectType.quantityType(forIdentifier: .bodyMass) {
            let healthKitTypesToRead: HKObjectType = type
            
            let healthStore = HKHealthStore()
            let authorizationStatus = healthStore.authorizationStatus(for: healthKitTypesToRead)
            
            switch authorizationStatus {
            case HKAuthorizationStatus.sharingAuthorized: return true
            case .sharingDenied: return false
            default: return false
            }
        }
        return false
    }
    
    public func isImperial() -> Bool {
        guard
            let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
            let currentUnitsType = UnitsType(rawValue: unitsTypePrefStr)
            else {
                return true
        }
        if currentUnitsType == .imperial {
            return true
        }
        return false
    }
    
    public func requestPermissions() {
        let dataTypes: Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
        
        healthStore.requestAuthorization(toShare: dataTypes, read: dataTypes, completion: { (success, error) in
            if success {
                //print("Authorization complete")
                self.fetchWeightData()
            } else {
                print("Authorization error: \(String(describing: error?.localizedDescription))")
            }
        })
        
    }
    
    public func submitWeight(weight: Double, forDate: Date) {
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let hkUnit = isImperial() ? HKUnit.pound() : HKUnit.gram() // HKUnit.pound()
        //HKUnit.gramUnit(with: HKMetricPrefix.kilo)
        let hkQuantity = HKQuantity.init(
            unit: hkUnit,
            doubleValue: weight)
        let bodyMass = HKQuantitySample(
            type: quantityType,
            quantity: hkQuantity,
            start: forDate,
            end: forDate)
        healthStore.save(bodyMass) { success, error in
            if error != nil {
                //print("Error: \(String(describing: error))")
            }
            if success {
                //print("Saved: \(success)")
            }
        }
    }
    
    public func fetchWeightData() {
        //Fetch the last 7 days of bodymass.
        let startDate = Date.init(timeIntervalSinceNow: -7*24*60*60) // :!!!: Healthkit param date
        let endDate = Date() // today, now. // :!!!: Healthkit param date
        fetchWeightData(startDate: startDate, endDate: endDate)
    }
    
    public func fetchWeightData(startDate: Date, endDate: Date) {
        //print("Fetching weight data")
        
        let quantityType: Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate)
        
        let sampleQuery = HKSampleQuery.init(
            sampleType: quantityType.first!, // weight
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil,
            resultsHandler: { (_: HKSampleQuery, hkSamples: [HKSample]?, _: Error?) in
                if let hkQuantitySamples = hkSamples as? [HKQuantitySample] {
                    DispatchQueue.main.async(execute: {
                        if !(hkSamples?.isEmpty)! {
                            NotificationCenter.default.post(
                                name: NSNotification.Name(rawValue: "BodyMassDataAvailable"),
                                object: hkQuantitySamples,
                                userInfo: nil)
                        }
                    })
                }
        })
        
        self.healthStore .execute(sampleQuery)
    }
    
    public func fetchWeightDataMorning() {
        //print("Fetching weight data")
        let now = Date()
        let earlier = Date(datestampKey: now.datestampKey)
        
        let quantityType: Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
        
        let predicate = HKQuery.predicateForSamples(
            withStart: earlier,
            end: now,
            options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let sampleQuery = HKSampleQuery.init(
            sampleType: quantityType.first!, // weight
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor],
            resultsHandler: { (_: HKSampleQuery, hkSamples: [HKSample]?, _: Error?) in
                if let hkQuantitySamples = hkSamples as? [HKQuantitySample] {
                    DispatchQueue.main.async(execute: {
                        if !(hkSamples?.isEmpty)! {
                            NotificationCenter.default.post(
                                name: NSNotification.Name(rawValue: "MorningBodyMassDataAvailable"),
                                object: hkQuantitySamples,
                                userInfo: nil)
                        }
                    })
                }
        })
        
        self.healthStore .execute(sampleQuery)
    }
    
    public func fetchWeightDataEvening() {
        //print("Fetching weight data")
        let now = Date()
        let earlier = Date(datestampKey: now.datestampKey)

        let quantityType: Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
        
        let predicate = HKQuery.predicateForSamples(
            withStart: earlier,
            end: now,
            options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery.init(
            sampleType: quantityType.first!, // weight
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor],
            resultsHandler: { (_: HKSampleQuery, hkSamples: [HKSample]?, _: Error?) in
                if let hkQuantitySamples = hkSamples as? [HKQuantitySample] {
                    DispatchQueue.main.async(execute: {
                        if !(hkSamples?.isEmpty)! {
                            NotificationCenter.default.post(
                                name: NSNotification.Name(rawValue: "EveningBodyMassDataAvailable"),
                                object: hkQuantitySamples,
                                userInfo: nil)
                        }
                    })
                }
        })
        
        self.healthStore .execute(sampleQuery)
    }

}
