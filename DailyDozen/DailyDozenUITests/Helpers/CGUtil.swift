//
//  CGUtil.swift
//  DailyDozenUITests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import Foundation
import CoreGraphics

struct CGUtil {
    private static let margin = CGFloat(1.0) 
    
    static func isCenter(_ a: CGRect, above b: CGRect) -> Bool {
        return a.midY < (b.minY - margin)
    }

    static func isCenter(_ a: CGRect, below b: CGRect) -> Bool {
        return a.midY > (b.maxY + margin)
    }

    static func isCenter(_ a: CGRect, outside b: CGRect) -> Bool {
        return isCenter(a, above: b) || isCenter(a, below: b)
    }

}
