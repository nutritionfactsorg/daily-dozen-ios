//
//  DatabaseBuiltInTest.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

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
