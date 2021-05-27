//
//  DatabaseBuiltInTest.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length
// swiftlint:disable type_body_length

import Foundation
import HealthKit

/// Utilities to support Built-In-Test (BIT).
public struct DatabaseBuiltInTest {
    
    static public var shared = DatabaseBuiltInTest()
    
    public let hkHealthStore = HKHealthStore()
    
    public func runSuite() { // :@@@:
        LogService.shared.debug(">>> :DEBUG:WAYPOINT: DatabaseBuiltInTest runSuite()")        
        LogService.shared.debug(">>> HKHealthStore.isHealthDataAvailable() \(HKHealthStore.isHealthDataAvailable())")
        
        //HealthManager.shared.exportHKWeight(name: "BIT00")
        //DatabaseBuiltInTest.shared.doGenerateDBHistoryBIT(numberOfDays: 3, defaultDB: false)
        //DatabaseBuiltInTest.shared.doGenerateDBHistoryBIT(numberOfDays: 365*3, defaultDB: false) // 1095 days, 2190 weight entries
        
        //doGenerateHKSampleDataBIT()
        // :!!!:NYI: BIT runSuite()
    }
    
    /// Clear Documents/Legacy, Documents/V01 and Library/Database/V02 Realm data.
    func doClearAllDataInMigrationChainBIT() {
        LogService.shared.debug(
            "••BEGIN•• UtilityTableViewController doClearAllDataInMigrationChainBIT()"
        )
        
        let urlLegacy = URL.inDocuments(filename: RealmProviderLegacy.realmFilename)
        let realmMngrLegacy = RealmManagerLegacy(fileUrl: urlLegacy)
        let realmDbOld = realmMngrLegacy.realmDb
        realmDbOld.deleteDBAllLegacy()
        
        let urlV01 = URL.inDocuments(filename: RealmProvider.realmFilename)
        let realmMngrV01 = RealmManager(fileURL: urlV01)
        let realmDbV01 = realmMngrV01.realmDb
        realmDbV01.deleteDBAll()
        
        let realmMngrV02 = RealmManager()
        let realmDbV02 = realmMngrV02.realmDb
        realmDbV02.deleteDBAll()
        
        LogService.shared.debug(
            "••EXIT•• UtilityTableViewController doClearAllDataInMigrationChainBIT()"
        )
    }
    
    func doGenerateDBLegacyDataBIT() {
        let urlLegacy = URL.inDocuments(filename: RealmProviderLegacy.realmFilename)
        let realmMngrLegacy = RealmManagerLegacy(fileUrl: urlLegacy)
        let realmDbLegacy = realmMngrLegacy.realmDb
        // World Pasta Day: Oct 25, 1995
        let date1995Pasta = Date(datestampKey: "19951025")!
        // Add known content to legacy
        let dozeCheck = realmDbLegacy.getDozeLegacy(for: date1995Pasta)
        realmDbLegacy.saveStatesLegacy([true, false, true], id: dozeCheck.items[0].id) // Beans
        realmDbLegacy.saveStatesLegacy([false, true, false], id: dozeCheck.items[2].id) // Other Fruit
    }
    
    func doGenerateDBV01DataBIT() {
        fatalError(":NYI: doGenerateDBV01DataBIT")
    } 
    
    func doGenerateDBV02DataBIT() {
        fatalError(":NYI: doGenerateDBV02DataBIT")
    } 
    
    /// Create initial state for 
    public func doGenerateHKSampleDataBIT() {
        let baseYMD = "20200521"
        let date1 = Date(datastampLong: "\(baseYMD)_073000.000")! // yyyyMMdd_HHmmss.SSS
        let date2 = Date(datastampLong: "\(baseYMD)_073100.000")!
        let date3 = Date(datastampLong: "\(baseYMD)_073100.000")!
        
        saveHKSampleBIT(date: date1, weight: 22.0, isImperial: false)
        saveHKSampleBIT(date: date2, weight: 24.2, isImperial: false)
        saveHKSampleBIT(date: date3, weight: 26.4, isImperial: false)
    }
    
    /// Generate Realm data
    ///
    /// * ~1 month -> 30 days 
    /// * ~10 months -> 300 days
    /// * ~2.7 years or ~33 months -> 1000 days (2000 weight entries)
    /// * 3 years (1095 days, 2190 weight entries) -> 365*3
    func doGenerateDBHistoryBIT(numberOfDays: Int, defaultDB: Bool) {
        LogService.shared.debug(
            "••BEGIN•• doGenerateDBHistoryBIT(\(numberOfDays))"
        )
        let urlLegacy = URL.inDocuments(filename: "test_\(numberOfDays)_days.realm")
        let realmMngrCheck = RealmManager(fileURL: urlLegacy)
        let realmProvider = realmMngrCheck.realmDb
        
        let calendar = Calendar.current
        let today = DateManager.currentDatetime() // today
        
        let dateComponents = DateComponents(
            calendar: calendar,
            year: today.year, month: today.month, day: today.day,
            hour: 0, minute: 0, second: 0
        )
        var date = calendar.date(from: dateComponents)!
        
        let weightBase = 65.0 // kg
        LogService.shared.debug("    baseWeigh \(weightBase) kg, \(weightBase * 2.2) lbs")
        let weightAmplitude = 2.0 // kg
        let weightCycleStep = (2 * Double.pi) / (30 * 2)
        for i in 0..<numberOfDays { 
            let stepByDay = DateComponents(day: -1)
            date = calendar.date(byAdding: stepByDay, to: date)!
            
            // Add data counts
            realmProvider.saveCount(3, date: date, countType: .dozeBeans) // 0-3
            realmProvider.saveCount(Int.random(in: 0...3), date: date, countType: .dozeFruitsOther) // 0-3
            
            let stepByAm = DateComponents(hour: Int.random(in: 7...8), minute: Int.random(in: 1...59))
            let dateAm = calendar.date(byAdding: stepByAm, to: date)!
            
            let stepByPm = DateComponents(hour: Int.random(in: 21...23), minute: Int.random(in: 1...59))
            let datePm = calendar.date(byAdding: stepByPm, to: date)!
            
            //
            let x = Double(i)
            let weightAm = weightBase + weightAmplitude * sin(x * weightCycleStep)
            let weightPm = weightBase - weightAmplitude * sin(x * weightCycleStep)
            
            realmProvider.saveDBWeight(date: dateAm, ampm: .am, kg: weightAm)
            realmProvider.saveDBWeight(date: datePm, ampm: .pm, kg: weightPm)
            
            if i < 5 {
                let weightAmStr = String(format: "%.2f", weightAm)
                let weightPmStr = String(format: "%.2f", weightAm)
                LogService.shared.debug(
                    "    \(date) [AM] \(dateAm) \(weightAmStr) [PM] \(datePm) \(weightPmStr)"
                )
            }
        }
        LogService.shared.debug(
            "••EXIT•• UtilityTableViewController doUtilityTestGenerateHistory(…)"
        )
    }
    
    func doGenerateDBHistoryLegacyBIT(numberOfDays: Int) {
        LogService.shared.debug(
            "••BEGIN•• doGenerateDBHistoryLegacyBIT(\(numberOfDays))"
        )
        let urlLegacy = URL.inDocuments(filename: "test_\(numberOfDays)_days_legacy.realm")
        let realmMngrCheckLegacy = RealmManagerLegacy(fileUrl: urlLegacy)
        let realmProviderLegacy = realmMngrCheckLegacy.realmDb
        
        let calendar = Calendar.current
        let today = DateManager.currentDatetime() // today
        
        let dateComponents = DateComponents(
            calendar: calendar,
            year: today.year, month: today.month, day: today.day,
            hour: 0, minute: 0, second: 0
        )
        var date = calendar.date(from: dateComponents)!
        
        for _ in 0..<numberOfDays { 
            let stepByDay = DateComponents(day: -1)
            date = calendar.date(byAdding: stepByDay, to: date)!
            let dozely = realmProviderLegacy.getDozeLegacy(for: date)
            
            // Add data states
            // #0 beans
            realmProviderLegacy.saveStatesLegacy([true, true, true], id: dozely.items[0].id)
            // #2 fruit
            realmProviderLegacy.saveStatesLegacy([Bool.random(), Bool.random(), Bool.random()], id: dozely.items[2].id)
            
            // pre 21 tweaks has no weight entries.
        }
        LogService.shared.debug(
            "••EXIT•• doGenerateDBHistoryLegacyBIT(…)"
        )
    }
    
    /// Generate Realm data for Streaks.
    ///
    /// ```
    ///                Bean:  14 days @3
    ///             Berries:   7 days @1
    ///        Other Fruits:   2 days @3
    /// 
    ///      Herbs & Spices: 100 days @1
    ///        Whole Grains: 100 days @3
    ///           Beverages: 100 days @6
    ///
    ///       Preload Water:  14 days @3
    ///    Negative Calorie:   7 days @3
    /// Incorporate Vinegar:   2 days @3
    /// 
    ///   Nutritional Yeast: 100 days @1
    ///               Cumin: 100 days @2
    ///           Green Tea: 100 days @3
    /// 
    ///  `Negative Calorie` and `Incorporate Vinegar` streak
    ///  are generated by updating the history sequence. 
    /// i =      0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
    ///         -----------------------------------------------
    ///         14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
    ///                x        x        x        x          
    /// 2-day    2  1  0  2  1  0  2  1  0  2  1  0  2  1  0 
    /// 
    ///          3  2  1  0  3  2  1  0  3  2  1  0  3  2  1  0
    ///                   +                       +        
    /// 7-day    7  6  5  4  3  2  1  0  7  6  5  4  3  2  1  0
    /// 
    /// ```
    func doGenerateDBStreaksBIT(busyBar: AlertBusyBar? = nil) {
        
        busyBar?.setProgress(0/12)
        
        let timeIn = Date().getCurrentBenchmarkSeconds
        let maxStreak = 7 // 100 (~minute), 999, 1000
        LogService.shared.debug(
            "••BEGIN•• doGenerateDBStreaksBIT()"
        )
        let realmMngr = RealmManager()
        let realmDb = realmMngr.realmDb
        
        let today = Date()
        // 2 days
        var timeA = Date().getCurrentBenchmarkSeconds
        for i in 0 ..< 2 {
            let date = today.adding(days: -i)
            realmDb.saveCount(3, date: date, countType: .dozeFruitsOther)
        }
        var timeB = Date().getCurrentBenchmarkSeconds
        LogService.shared.debug("\t2\ttime=\t\(timeB - timeA)\tsec")
        busyBar?.setProgress(1/12)

        // 7 days 
        timeA = timeB
        for i in 0 ..< 7 {
            let date = today.adding(days: -i)
            realmDb.saveCount(1, date: date, countType: .dozeBerries)
        }
        timeB = Date().getCurrentBenchmarkSeconds
        LogService.shared.debug("\t7\ttime=\t\(timeB - timeA)\tsec")
        busyBar?.setProgress(2/12)

        // 14 days
        timeA = timeB
        for i in 0 ..< 14 {
            let date = today.adding(days: -i)
            realmDb.saveCount(3, date: date, countType: .dozeBeans)
        }
        timeB = Date().getCurrentBenchmarkSeconds
        LogService.shared.debug("\t14\ttime=\t\(timeB - timeA)\tsec")
        busyBar?.setProgress(3/12)

        // Max streak days
        timeA = timeB
        for i in 0 ..< maxStreak {
            let date = today.adding(days: -i)
            realmDb.saveCount(1, date: date, countType: .dozeSpices)
        }
        timeB = Date().getCurrentBenchmarkSeconds
        LogService.shared.debug("\t\(maxStreak)\ttime=\t\(timeB - timeA)\tsec")
        busyBar?.setProgress(4/12)
        timeA = timeB
        for i in 0 ..< maxStreak {
            let date = today.adding(days: -i)
            realmDb.saveCount(3, date: date, countType: .dozeWholeGrains)
        }
        timeB = Date().getCurrentBenchmarkSeconds
        LogService.shared.debug("\t\(maxStreak)\ttime=\t\(timeB - timeA)\tsec")
        busyBar?.setProgress(5/12)
        timeA = timeB
        for i in 0 ..< maxStreak {
            let date = today.adding(days: -i)
            realmDb.saveCount(5, date: date, countType: .dozeBeverages)
        }
        timeB = Date().getCurrentBenchmarkSeconds
        LogService.shared.debug("\t\(maxStreak)\ttime=\t\(timeB - timeA)\tsec")
        busyBar?.setProgress(6/12)

        // 2 days: by editing streak history with 0
        timeA = timeB
        for i in (0 ..< 14).reversed() {
            let date = today.adding(days: -i)
            realmDb.saveCount(3, date: date, countType: .tweakMealVinegar)
        }
        for i in [2, 5, 8, 11, 14] { // zero every third day.
            let date = today.adding(days: -i)
            realmDb.saveCount(0, date: date, countType: .tweakMealVinegar)
        }
        timeB = Date().getCurrentBenchmarkSeconds
        LogService.shared.debug("\t19\ttime=\t\(timeB - timeA)\tsec")
        busyBar?.setProgress(7/12)

        // 7 days: by editing streak history to add full count
        timeA = timeB
        for i in (0 ..< 15).reversed() {
            let date = today.adding(days: -i)
            if i % 4 == 3 {
                realmDb.saveCount(0, date: date, countType: .tweakMealNegCal)
            } else {
                realmDb.saveCount(3, date: date, countType: .tweakMealNegCal)                
            }
        }
        for i in [3, 11] { // complete days to create 7-streak.
            let date = today.adding(days: -i)
            realmDb.saveCount(3, date: date, countType: .tweakMealNegCal)
        }
        timeB = Date().getCurrentBenchmarkSeconds
        LogService.shared.debug("\t16\ttime=\t\(timeB - timeA)\tsec")
        busyBar?.setProgress(8/12)

        // 14 days
        timeA = timeB
        for i in (0 ..< 14).reversed() {
            let date = today.adding(days: -i)
            realmDb.saveCount(3, date: date, countType: .tweakMealWater)
        }
        timeB = Date().getCurrentBenchmarkSeconds
        LogService.shared.debug("\t14\ttime=\t\(timeB - timeA)\tsec")
        busyBar?.setProgress(9/12)

        // Max streak days
        timeA = timeB
        for i in (0 ..< maxStreak).reversed() {
            let date = today.adding(days: -i)
            realmDb.saveCount(1, date: date, countType: .tweakDailyNutriYeast)
        }
        timeB = Date().getCurrentBenchmarkSeconds
        LogService.shared.debug("\t\(maxStreak)\ttime=\t\(timeB - timeA)\tsec")
        busyBar?.setProgress(10/12)
        timeA = timeB
        for i in (0 ..< maxStreak).reversed() {
            let date = today.adding(days: -i)
            realmDb.saveCount(2, date: date, countType: .tweakDailyCumin)
        }
        timeB = Date().getCurrentBenchmarkSeconds
        LogService.shared.debug("\t\(maxStreak)\ttime=\t\(timeB - timeA)\tsec")
        busyBar?.setProgress(11/12)
        timeA = timeB
        for i in (0 ..< maxStreak).reversed() {
            let date = today.adding(days: -i)
            realmDb.saveCount(3, date: date, countType: .tweakDailyGreenTea)
        }
        timeB = Date().getCurrentBenchmarkSeconds
        LogService.shared.debug("\t\(maxStreak)\ttime=\t\(timeB - timeA)\tsec")
        busyBar?.setProgress(12/12)

        let timeOut = Date().getCurrentBenchmarkSeconds
        let lapsed = timeOut - timeIn
        LogService.shared.debug(
            "••EXIT•• UtilityTableViewController doGenerateDBStreaksBIT() \(lapsed) sec"
        )
        busyBar?.completed()
    }
    
    // MARK: - Unsynced HK Actions
    // Unsynced HealthKit actions to setup to support testing.
    
    /// 
    public func saveHKSampleBIT(date: Date, weight: Double, isImperial: Bool) {
        HealthManager.shared.saveHKWeight(date: date, weight: weight, isImperial: isImperial, metadata: ["DailyDozen": "BIT"])
    }
    
    public func readAllHKSamplesBIT() {
        HealthManager.shared.readHKWeight(key: "DailyDozen", values: ["BIT"])
    }
    
    public func deleteAllHKSamplesBIT() {
        // check for BIT in metadata
        HealthManager.shared.deleteHKWeight(key: "DailyDozen", values: ["BIT"])
    }
    
}
