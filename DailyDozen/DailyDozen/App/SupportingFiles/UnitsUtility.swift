//
//  UnitsUtility.swift
//  DailyDozen
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import Foundation

/// **Notes: Regional Weight Values**
///
///  The canonical, normalized weight is kilograms as a Double
///
/// * range, persisted maximum: 4 kg to 400 kg
/// * resolution, export/import: two decimal places
/// * resolution, persisted minimum: 0.05 kg, 0.1 lb

public enum UnitsWeightError: String, Error {
    case outOfRange = "Out of allowed range: 4 kg to 400 kg"
    case parsingError = "Parsing Error: string must contain only numerical digits, and locale-appropriate group or decimal separators"
}

struct UnitsUtility {

    public static func convertKgToLbs(_ kg: Double) -> Double {
        let lbs = kg * 2.204623
        return lbs
    }
    
    public static func convertKgToLbs(_ string: String, toDecimalDigits: Int = 1) -> String? {
        if let kg = normalizedKgWeight(from: string, fromUnits: .metric) {
            return regionalLbsWeight(fromKg: kg, toDecimalDigits: toDecimalDigits)
        } else {
            return nil
        }
    }
    
    public static func convertLbsToKg(_ lbs: Double) -> Double {
        let kg = lbs / 2.204623
        return kg
    }

    public static func convertLbsToKg(_ string: String, toDecimalDigits: Int = 1) -> String? {
        if let kg = normalizedKgWeight(from: string, fromUnits: .imperial) {
            return regionalKgWeight(fromKg: kg, toDecimalDigits: toDecimalDigits)
        } else {
            return nil
        }
    }
    
    /// normalizes regional weight text is a `Double` in kilograms
    public static func normalizedKgWeight(
        from: String,
        fromUnits: UnitsType
    ) -> Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        guard var weight = formatter.number(from: from)?.doubleValue
        else {
            //throw UnitsWeightError.parsingError
            return nil
        }
        
        switch fromUnits {
        case .imperial:
            weight = weight / 2.2046 // kg = lbs * 2.2046
        case .metric:
            break // text in metric kg format. no conversion required.
        }

        // range check
        if weight < 4.0 || weight > 400 {
            return nil
        }
        return weight
    }

    /// returns regionalized weigh text from kg `Double`
    public static func regionalWeight(
        fromKg: Double,
        toUnits: UnitsType,
        toDecimalDigits: Int
    ) -> String? {
        switch toUnits {
        case .imperial:
            return regionalLbsWeight(fromKg: fromKg, toDecimalDigits: toDecimalDigits)
        case .metric:
            return regionalKgWeight(fromKg: fromKg, toDecimalDigits: toDecimalDigits)
        }
    }

    /// returns regionalized weigh text in kg from kg `Double`
    public static func regionalKgWeight(
        fromKg: Double,
        toDecimalDigits: Int
    ) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = toDecimalDigits
        
        let nsNumber = NSNumber(value: fromKg)
        return formatter.string(from: nsNumber)
    }
    
    /// returns regionalized weigh text in pounds from kg `Double`
    public static func regionalLbsWeight(
        fromKg: Double,
        toDecimalDigits: Int
    ) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = toDecimalDigits
        
        let poundValue = fromKg * 2.204623
        let nsNumber = NSNumber(value: poundValue)
        return formatter.string(from: nsNumber)
    }

}
