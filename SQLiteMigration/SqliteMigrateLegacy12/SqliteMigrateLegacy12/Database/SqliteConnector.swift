//
//  SqliteConnector.swift
//  SqliteMigrateLegacy12/Database
//
//  Copyright © 2023 NutritionFacts.org. All rights reserved.
//

import Foundation
import LogService
import SQLiteApi

struct SqliteConnector {
    static var run = SqliteConnector()
    
    let dbUrl: URL
    let sqliteApi: SQLiteApi
    
    init() {
        dbUrl = URL.inLibrary(filename: "DailyDozen1.sqlite3")
        sqliteApi = SQLiteApi(dbUrl: dbUrl)
    }
    
    func clearDb() {
        print("run clearDb")
    }

    func createData() {
        print("run createData")
        //let r = SqlDataCountRecord(date: Date(), countType: .dozeBeans, count: 2, streak: 0)
        //sqliteApi.dataCount.create(r)
        // 3 * 365 = 1095
        //doGenerateDBHistoryBIT(numberOfDays: 1095, defaultDB: true)
        doGenerateDBHistoryBIT(numberOfDays: 28, defaultDB: true)
    }

    func exportData() {
        print("run exportData")
    }

    func importData() {
        print("run importData")
    }
    
    func timingTest() {
        print("run timingTest")
    }
    
    /// Generate data
    ///
    /// * ~1 month -> 30 days 
    /// * ~10 months -> 300 days
    /// * ~2.7 years or ~33 months -> 1000 days (2000 weight entries)
    /// * 3 years (1095 days, 37230 count entries, 2190 weight entries) -> 365*3
    func doGenerateDBHistoryBIT(numberOfDays: Int, defaultDB: Bool) {
        LogService.shared.debug(
            "••BEGIN•• doGenerateDBHistoryBIT(\(numberOfDays))  \(Date())"
        )
        //let urlLegacy = URL.inDocuments(filename: "test_\(numberOfDays)_days.realm")
        sqliteApi.transactionBegin()
        
        let calendar = Calendar.current
        let today = Date() // today
        
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
            
            // --- COUNT RECORDS ---
            for countType in DataCountType.allCases {
                // Add data counts
                let r = SqlDataCountRecord(date: date, countType: countType, count: 1, streak: 0)
                sqliteApi.dataCount.create(r)
            }
            
            // --- WEIGHT RECORDS ---
            let stepByAm = DateComponents(hour: Int.random(in: 7...8), minute: Int.random(in: 1...59))
            let dateAm = calendar.date(byAdding: stepByAm, to: date)!
            
            let stepByPm = DateComponents(hour: Int.random(in: 21...23), minute: Int.random(in: 1...59))
            let datePm = calendar.date(byAdding: stepByPm, to: date)!
            
            //
            let x = Double(i)
            let weightAm = weightBase + weightAmplitude * sin(x * weightCycleStep)
            let weightPm = weightBase - weightAmplitude * sin(x * weightCycleStep)
            
            //realmProvider.saveDBWeight(date: dateAm, ampm: .am, kg: weightAm)
            //realmProvider.saveDBWeight(date: datePm, ampm: .pm, kg: weightPm)
            
            let nToLog = 5
            if i == 0 {
                LogService.shared.debug("•• first \(nToLog) weight entries")
            }
            if i < nToLog {
                let weightAmStr = String(format: "%.2f", weightAm)
                let weightPmStr = String(format: "%.2f", weightAm)
                LogService.shared.debug(
                    "    \(date) [AM] \(dateAm) \(weightAmStr) [PM] \(datePm) \(weightPmStr)"
                )
            }
        }
        sqliteApi.transactionCommit()
        LogService.shared.debug(
            "••EXIT•• doUtilityTestGenerateHistory(…) \(Date())"
        )
    }
    
}

