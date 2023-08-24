//
//  SQLiteBuiltInTest.swift
//  DailyDozen
//
//  Created by mc on 8/23/23.
//  Copyright © 2023 Nutritionfacts.org. All rights reserved.
//

import Foundation
import HealthKit

/// Utilities to support Built-In-Test (BIT).
public struct SQLiteBuiltInTest {
    static public var shared = SQLiteBuiltInTest()
    
    public let hkHealthStore = HKHealthStore()
    
}
