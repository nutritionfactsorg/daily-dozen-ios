//
//  SQLiteConnector.swift
//  Database
//
//  Copyright © 2023 NutritionFacts.org. All rights reserved.
//
// swiftlint:disable type_body_length
// swiftlint:disable file_length

import Foundation

struct SQLiteConnector {
    static var dot = SQLiteConnector()
    //
    public static let sqliteFilename = "NutritionFacts.sqlite3"
    /// csvExerciseGamut may differ from SettingsManager.exerciseGamut()
    var csvExerciseGamut: ExerciseGamut
    /// csvUnitsType may differ from SettingsManager.unitsType()
    var csvUnitsType: UnitsType
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
        // Initialize to user preferences
        csvExerciseGamut = SettingsManager.exerciseGamut()
        csvUnitsType = SettingsManager.unitsType()
    }
    
    // MARK: Advanced Utilities Connection
    
    func clearDb() {
        logit.info("run clearDb")
    }
    
    func createData() {
        logit.info("run SQLiteConnector Utility createData 28 days")
        generateHistoryBIT(numberOfDays: 28)
    }
    
    func exportData() {
        logit.info(":GTD:NYI: SQLiteConnector Utility exportData()")
    }
    
    func importData() {
        logit.info(":GTD:NYI: SQLiteConnector Utility importData()")
    }
    
    func timingTest() {
        logit.info(":GTD:NYI: SQLiteConnector Utility timingTest()")
    }
    
    // MARK: - Export & Import CSV Connection
    
    func csvExport(marker: String, activity: ActivityProgress? = nil) -> String {
        let filename = "\(marker)-\(Date.datestampExport()).csv"
        csvExport(filename: filename, activity: activity)
        return filename
    }
    
    func csvExport(filename: String, activity: ActivityProgress? = nil) {
        let outUrl = URL.inDocuments().appendingPathComponent(filename)
        var content = csvKeysHeader()
        content.append(csvUnitsHeader() + "\n")
        
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
        if csvUnitsType == .imperial {
            str.append(",\(tracker.weightAM.time)")
            str.append(",\(tracker.weightAM.lbsStr)")
            str.append(",\(tracker.weightPM.time)")
            str.append(",\(tracker.weightPM.lbsStr)")
            str.append("\n")
        } else {
            str.append(",\(tracker.weightAM.time)")
            str.append(",\(tracker.weightAM.kgStr)")
            str.append(",\(tracker.weightPM.time)")
            str.append(",\(tracker.weightPM.kgStr)")
            str.append("\n")
        }
        
        return str
    }
    
    mutating func csvImport(filename: String) {
        let inUrl = URL.inDocuments().appendingPathComponent(filename)
        csvImport(url: inUrl)
    }
    
    mutating func csvImport(url: URL) {
        guard let contents = try? String(contentsOf: url)  else {
            logit.error(
                "FAIL: csvImport file not found '\(url.lastPathComponent)'"
            )
            return
        }
        let lines = contents.components(separatedBy: .newlines)
        
        guard lines.count >= 2 else {
            logit.error("csvImport file without data")
            return
        }
        guard isValidCsvKeysHeader(lines[0]) else {
            logit.error("FAIL: csvImport invalid keys header")
            return
        }
        
        if lines[1].hasPrefix("[UNITS]") {
            if isValidSetCsvUnitsHeader(lines[1]) {
                logit.info("[UNITS] csvExerciseGamut=\(csvExerciseGamut), csvUnitsType=\(csvUnitsType)")
            } else {
                logit.error("FAIL: [UNITS] row invalid")
                return
            }
        } else {
            // No [UNITS] row: exercise is 1 unit. weight is kg
            csvExerciseGamut = ExerciseGamut.one
            csvUnitsType = .metric
            if let dailyTracker = csvImportLine(lines[1]) {
                sqliteApi.saveDailyTracker(tracker: dailyTracker)
            } else {
                logit.error("FAIL: 1st data row invalid")
                return
            }
        }
        
        var skippedLineCount = 0
        for i in 2..<lines.count {
            if let dailyTracker = csvImportLine(lines[i]) {
                sqliteApi.saveDailyTracker(tracker: dailyTracker)
            } else {
                skippedLineCount += 1
            }
        }
        logit.debug("csvImport skippedLineCount==\(skippedLineCount)")
        
        // Restore to user preferences
        csvExerciseGamut = SettingsManager.exerciseGamut()
        csvUnitsType = SettingsManager.unitsType()
    }
    
    private func csvImportLine(_ line: String) -> SqlDailyTracker? {
        let columns = line.replacingOccurrences(of: " ", with: "")
            .components(separatedBy: ",")
        // column count = date(1) + checkboxes(n) + weight(4)
        guard columns.count == 1 + DataCountType.allCases.count + 4 else {
            return nil
        }
        // Process date column
        let datastampKey = columns[0]
        guard let date = Date(datestampKey: datastampKey) else {
            return nil
        }
        var tracker = SqlDailyTracker(date: date)
        // Process checkbox datacount columns
        var index = 1
        for dataCountType in DataCountType.allCases {
            //guard var value = Int(columns[index])
            guard let value = Int(columns[index])
            else {
                logit.error("FAIL: csvImportLine @index=\(index) in \(line)")
                return nil
            }
            
            let sqlDataCountRecord = SqlDataCountRecord(
                date: date,
                countType: dataCountType,
                count: value
            )
            tracker.itemsDict[dataCountType] = sqlDataCountRecord
            index += 1
        }
        // Process weight columns
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
    
    // MARK: - CSV Headers
    
    /// CSV 1st Header Line: Key Names
    private func csvKeysHeader() -> String {
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
    
    /// CSV 2nd Header Line: Units 100% goal, exercise gamut, weight units
    /// Based on csvExerciseGamut, csvUnitsType values.
    private func csvUnitsHeader() -> String {
        var str = "[UNITS]"
        // 100% Goals
        for dataCountType in DataCountType.allCases {
            if dataCountType == .dozeExercise {
                str.append(",\(csvExerciseGamut.int)")
            } else {
                str.append(",\(dataCountType.goalServings)")
            }
        }
        // Weight // :GTD:[UNITS]: kg|lbs
        if csvUnitsType == .imperial {
            str.append(",[am]")  // Weight AM Time
            str.append(",[lbs]") // Weight AM Value
            str.append(",[pm]")  // Weight PM Time
            str.append(",[lbs]") // Weight PM Value
        } else {
            str.append(",[am]")  // Weight AM Time
            str.append(",[kg]")  // Weight AM Value
            str.append(",[pm]")  // Weight PM Time
            str.append(",[kg]")  // Weight PM Value
        }
        return str
    }
    
    private func isValidCsvKeysHeader(_ header: String) -> Bool {
        let currentHeaderNormalized = header
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
            .appending("\n")
        
        let referenceHeaderNormalize = csvKeysHeader()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
        
        return currentHeaderNormalized == referenceHeaderNormalize
    }
    
    /// Validates and sets 
    private mutating func isValidSetCsvUnitsHeader(_ header: String, withSet: Bool = true) -> Bool {
        let inboundHeaderNormalized = header
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
        
        let columns = inboundHeaderNormalized.components(separatedBy: ",")
        guard 
            columns.count == 41,
            let gamut = ExerciseGamut(columns[12]), // dozeExercies "Exercise"
            let unitsAM = UnitsType(mass: columns[38]), // AM Units
            let unitsPM = UnitsType(mass: columns[40]), // PM Units
            unitsAM == unitsPM
        else { return false }
        
        csvExerciseGamut = gamut
        csvUnitsType = unitsAM
        
        let referenceHeaderNormalize = csvUnitsHeader()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
        
        if inboundHeaderNormalized == referenceHeaderNormalize {
            return true
        } else {
            logit.error("isValidSetCsvUnitsHeader() match failed")
            return false
        }
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
            "••BEGIN•• SQLiteConnector generateHistoryBIT(\(numberOfDays))  \(Date())"
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
                    "    \(date) [am] \(dateAM) \(weightAmStr) [pm] \(datePM) \(weightPmStr)"
                )
            }
            
            let stepByDay = DateComponents(day: -1)
            date = calendar.date(byAdding: stepByDay, to: date)!
        }
        sqliteApi.transactionCommit()
        logit.debug(
            "•••END••• SqliteConnector generateHistoryBIT(…) \(Date())"
        )
    }
    
}
