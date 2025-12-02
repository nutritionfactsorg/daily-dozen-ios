//
//  HealthManager.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import Foundation
import HealthKit
// If the user denied the authorization request,
// HealthKit only provides information written by the app and nothing else.
// https://developer.apple.com/documentation/HealthKit/HKAuthorizationStatus

// HKQuantityType > HKSampleType > HKObjectType

/// HealthManager provides read, save, delete layer for HealthKit.
///
/// //TBDz only transferred part of HealthManager
class HealthManagerWAS {
    
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
    //TBDz  HKSampleType is deprecated need to use
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
                    print("•HK• HealthManager Authorization success")
                    print("•HK• HealthManager Authorization success")
                } else {
                     print("•HK• HealthManager Authorization error: \(String(describing: error?.localizedDescription))")
                   // print("HK error \(String(describing: error?.localizedDescription))")
                }
            })
    }
    
}
