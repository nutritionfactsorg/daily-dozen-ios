//
//  SQLiteConnector.swift
//  Database
//
//  Copyright © 2023 NutritionFacts.org. All rights reserved.
//

import Foundation

struct SQLiteConnector {
    static var dot = SQLiteConnector()
    //
    public static let sqliteFilename = "NutritionFacts.sqlite3"
    
    let dbUrl: URL
    let sqliteApi: SQLiteApi
    
    init() {
        let databaseDir = URL.inDatabase()
        let fm = FileManager.default
        if fm.fileExists(atPath: databaseDir.path) == false {
            do {
                try fm.createDirectory(at: databaseDir, withIntermediateDirectories: true)
            } catch {
                logit.error("SQLiteConnector failed to create Database/")
            }
        }
        
        dbUrl = URL.inDatabase(filename: SQLiteConnector.sqliteFilename)
        sqliteApi = SQLiteApi(dbUrl: dbUrl)
    }
    
    // MARK: Advanced Utilities Connection
    
    func clearDb() {
        logit.info("run clearDb")
    }
    
    func createData() {
        logit.info("run SQLiteConnector Utility createData")
        generateHistoryBIT(numberOfDays: 28)
    }
    
    func exportData() {
        logit.info(":NYI: SQLiteConnector Utility exportData()") // :GTD:
    }
    
    func importData() {
        logit.info(":NYI: SQLiteConnector Utility importData()") // :GTD:
    }
    
    func timingTest() {
        logit.info(":NYI: SQLiteConnector Utility timingTest()") // :GTD:
    }
    
    // MARK: - Export & Import TSV Connection
    
    func csvExport(marker: String, activity: ActivityProgress? = nil) -> String {
        let filename = "\(marker)-\(Date.datestampExport()).csv"
        csvExport(filename: filename, activity: activity)
        return filename
    }
    
    func csvExport(filename: String, activity: ActivityProgress? = nil) {
        let outUrl = URL.inDocuments().appendingPathComponent(filename)
        var content = SQLiteConnector.csvHeader
        content.append(SQLiteConnector.csvHeaderLine2)
        
        let allTrackers = sqliteApi.getDailyTrackers(activity: activity)
        let trackerCount = allTrackers.count
        
        let activityStepsTotal: Float = 50.0 // 50 progress steps
        var activityStepIdx = 0
        let activityStepSize = Int((Float(trackerCount) / activityStepsTotal).rounded(.up))
        activity?.setProgress(ratio: 0.0, text: "0%")
        
        for i in 0 ..< allTrackers.count {
            let tracker = allTrackers[i]
            content.append(csvExportLine(tracker: tracker))
            
            if i > activityStepIdx * activityStepSize {
                let ratio = Float(i) / Float(trackerCount)
                let percent = (100 * ratio).rounded(.down)
                let text = "\(Int(percent))%"
                activity?.setProgress(ratio: ratio, text: text)
                activityStepIdx += 1
            }
        }
        
        do {
            try content.write(to: outUrl, atomically: true, encoding: .utf8)
        } catch {
            logit.error(
                "FAIL SQLiteConnector csvExport \(error) path:'\(outUrl.path)'"
            )
        }
    }
    
    private func csvExportLine(tracker: SqlDailyTracker) -> String {
        var str = ""
        str.append("\(tracker.date.datestampKey)")
        
        for dataCountType in DataCountType.allCases {
            if let sqlDataCountRecord = tracker.itemsDict[dataCountType] {
                str.append(",\(sqlDataCountRecord.count)")
            } else {
                str.append(",0")
            }
        }
        // Weight
        str.append(",\(tracker.weightAM.time)")
        str.append(",\(tracker.weightAM.kgStr)")
        str.append(",\(tracker.weightPM.time)")
        str.append(",\(tracker.weightPM.kgStr)")
        str.append("\n")
        
        return str
    }
    
    func csvImport(filename: String) {
        let inUrl = URL.inDocuments().appendingPathComponent(filename)
        csvImport(url: inUrl)
    }
    
    func csvImport(url: URL) {
        guard let contents = try? String(contentsOf: url)  else {
            logit.error(
                "FAIL SQLiteConnector csvImport file not found '\(url.lastPathComponent)'"
            )
            return
        }
        let lines = contents.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            logit.error(
                "FAIL SQLiteConnector csvImport CSV has less that 2 lines"
            )
            return
        }
        
        if isValidCsvHeader(lines[0]) {
            
            if lines.count >= 2 {
                if lines[1].hasPrefix("(GOAL)") {
                    // :NYI: check/set basis for execercise units, weight kg/lbs
                } else {
                    if let dailyTracker = csvProcess(line: lines[1]) {
                        sqliteApi.saveDailyTracker(tracker: dailyTracker)
                    }
                }
            }
            
            for i in 2..<lines.count {
                if let dailyTracker = csvProcess(line: lines[i]) {
                    sqliteApi.saveDailyTracker(tracker: dailyTracker)
                }
            }
        } else {
            logit.error(
                "FAIL SQLiteConnector csvImport CSV does not contain a valid header line"
            )
            return
        }
        
    }
    
    private func csvProcess(line: String) -> SqlDailyTracker? {
        let columns = line
            .replacingOccurrences(of: " ", with: "")
            .components(separatedBy: ",")
        guard columns.count == 1 + DataCountType.allCases.count + 4 else {
            return nil
        }
        
        let datastampKey = columns[0]
        guard let date = Date(datestampKey: datastampKey) else {
            return nil
        }
        var tracker = SqlDailyTracker(date: date)
        
        var index = 1
        for dataCountType in DataCountType.allCases {
            if let value = Int(columns[index]) {
                let sqlDataCountRecord = SqlDataCountRecord(
                    date: date,
                    countType: dataCountType,
                    count: value
                )
                tracker.itemsDict[dataCountType] = sqlDataCountRecord
            } else {
                logit.error(
                    "FAIL SQLiteConnector csvProcess \(index) in \(line)"
                )
            }
            index += 1
        }
        
        let weightIndexOffset = 1 + DataCountType.allCases.count
        let weightAM = SqlDataWeightRecord(
            datestampSid: datastampKey,
            typeKey: DataWeightType.am.typeKey,
            kilograms: columns[weightIndexOffset],
            timeHHmm: columns[weightIndexOffset+1]
        )
        if let weight = weightAM {
            tracker.weightAM = weight
        }
        let weightPM = SqlDataWeightRecord(
            datestampSid: datastampKey,
            typeKey: DataWeightType.pm.typeKey,
            kilograms: columns[weightIndexOffset+2],
            timeHHmm: columns[weightIndexOffset+3]
        )
        if let weight = weightPM {
            tracker.weightPM = weight
        }
        
        return tracker
    }
    
    private func isValidCsvHeader(_ header: String) -> Bool {
        let currentHeaderNormalized = header
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
            .appending("\n")
        
        let referenceHeaderNormalize = SQLiteConnector.csvHeader
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
        
        return currentHeaderNormalized == referenceHeaderNormalize
    }
    
    private static var csvHeader: String {
        var str = "Date"
        for dataCountType in DataCountType.allCases {
            str.append(",\(dataCountType.headingCSV)")
        }
        // Weight
        str.append(",Weight AM Time")
        str.append(",Weight AM Value")
        str.append(",Weight PM Time")
        str.append(",Weight PM Value")
        
        str.append("\n")
        return str
    }
    
    private static var csvHeaderLine2: String {
        var str = "(GOAL)"
        for dataCountType in DataCountType.allCases {
            str.append(",\(dataCountType.goalServings)")
        }
        // Weight
        str.append(",-AM-") // Weight AM Time
        str.append(",kg")   // Weight AM Value
        str.append(",-PM-") // Weight PM Time
        str.append(",kg")   // Weight PM Value
        
        str.append("\n")
        return str
    }
    
    // MARK: - Built In Test (BIT) Connection
    
    /// Generate data
    ///
    /// - ~1 month -> 30 days 
    /// - ~10 months -> 300 days
    /// - ~2.7 years or ~33 months -> 1000 days (2000 weight entries)
    /// - 3 years (1095 days, 37230 count entries, 2190 weight entries) -> `3*365`
    func generateHistoryBIT(numberOfDays: Int) {
        logit.debug(
            "••BEGIN•• generateHistoryBIT(\(numberOfDays))  \(Date())"
        )
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
        logit.debug("    baseWeigh \(weightBase) kg, \(weightBase * 2.2) lbs")
        let weightAmplitude = 2.0 // kg
        let weightCycleStep = (2 * Double.pi) / (30 * 2)
        for i in 0..<numberOfDays {
            // --- COUNT RECORDS ---
            for countType in DataCountType.allCases {
                // Add data counts
                let r = SqlDataCountRecord(date: date, countType: countType, count: 1, streak: 0)
                sqliteApi.dataCount.create(r)
            }
            
            // --- WEIGHT RECORDS ---
            let stepByAM = DateComponents(hour: Int.random(in: 7...8), minute: Int.random(in: 1...59))
            let dateAM = calendar.date(byAdding: stepByAM, to: date)!
            
            let stepByPM = DateComponents(hour: Int.random(in: 21...23), minute: Int.random(in: 1...59))
            let datePM = calendar.date(byAdding: stepByPM, to: date)!
            
            //
            let x = Double(i)
            let weightAM = weightBase + weightAmplitude * sin(x * weightCycleStep)
            let weightPM = weightBase - weightAmplitude * sin(x * weightCycleStep)
            
            let rAM = SqlDataWeightRecord(date: dateAM, weightType: .am, kg: weightAM)
            sqliteApi.dataWeight.create(rAM)
            let rPM = SqlDataWeightRecord(date: datePM, weightType: .pm, kg: weightPM)            
            sqliteApi.dataWeight.create(rPM)
            
            let nToLog = 5
            if i == 0 {
                logit.debug("•• first \(nToLog) weight entries")
            }
            if i < nToLog {
                let weightAmStr = String(format: "%.2f", weightAM)
                let weightPmStr = String(format: "%.2f", weightAM)
                logit.debug(
                    "    \(date) [AM] \(dateAM) \(weightAmStr) [PM] \(datePM) \(weightPmStr)"
                )
            }
            
            let stepByDay = DateComponents(day: -1)
            date = calendar.date(byAdding: stepByDay, to: date)!
        }
        sqliteApi.transactionCommit()
        logit.debug(
            "••EXIT•• SqliteConnector generateHistoryBIT(…) \(Date())"
        )
    }
    
}
