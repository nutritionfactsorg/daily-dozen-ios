//
//  HealthWeightRecord.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import Foundation
import HealthKit

/// Notification passthrough structure for HealthKit completion handlers.
struct HealthWeightRecord {
    
    let ampm: DataWeightType
    var hkWeightSamples: [HKQuantitySample]
    
    init(ampm: DataWeightType, hkWeightSamples: [HKQuantitySample]) {
        self.ampm = ampm
        self.hkWeightSamples = hkWeightSamples
    }
    
    /// Weight data to show to user "IB"
    func getIBWeightToShow() -> (time: String, weight: String) {        
        // Return "first" HK weight record if present
        guard let sample = hkWeightSamples.first else {
            return (time: "", weight: "")
        } 
        
        let bodymassKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
        var weight = Double(bodymassKg)
        if SettingsManager.isImperial() {
            weight = weight * 2.2046 // 1 kg = 2.2046 lbs
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let timeStr = dateFormatter.string(from: sample.startDate)
        let weightStr = String(format: "%.1f", weight)
        return (time: timeStr, weight: weightStr)
    }
    
    func toString() -> String {
        var s = ""
        
        for sample: HKQuantitySample in hkWeightSamples {
            s.append( "\(sample.uuid) " )
            s.append( "\(sample.startDate.datestampyyyyMMddHHmmss) " )
            
            // -- HKQuantity > Double > kilo|pound --
            let quantity: HKQuantity = sample.quantity
            let kiloValue = quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            let kiloStr = String(format: "%.1f", kiloValue)
            s.append( "\(kiloStr)kg " )
            
            let poundValue = quantity.doubleValue(for: HKUnit.pound())
            let poundStr = String(format: "%.1f", poundValue)
            s.append( "\(poundStr)lbs " )
            
            // -- HKQuantityType > HKQuantityAggregationStyle --
            // -- Double,  discreteArithmetic
            //let quantityType: HKQuantityType = sample.quantityType
            //let aggregationStyle: HKQuantityAggregationStyle = quantityType.aggregationStyle
            //s.append( "style:\(aggregationStyle.rawValue) " )
            //quantityType.isMaximumDurationRestricted // iOS 13+
            //quantityType.isMinimumDurationRestricted // iOS 13+
            
            // -- HKSourceRevision > HKSource --
            let sourceRevision = sample.sourceRevision
            //sourceRevision.operatingSystemVersion.majorVersion
            let source: HKSource = sourceRevision.source
            // com.nutritionfacts.dailydozen DailyDozen
            // com.apple.Health              Health  
            s.append("\(source.bundleIdentifier) \(source.name) ")
            
            // --- METADATA ---
            // metadata: { HKWasUserEntered = 1; } created by Health app
            //s.metadata       // [String: Any]?
            
            //s.append( "\n" )
            //s.append( "*** \(sample.debugDescription) ***\n" )
            //s.append( "### \(sample.description) ###\n" )
            //s.append( "\((sample.device != nil) ? sample.device.debugDescription : "nil-device")\n" )
            
            s.append("\n")
        }
        
        return s
    }
    
}
