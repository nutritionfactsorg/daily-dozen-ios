//
//  SQLiteConnector.swift
//  SQLiteFramework
//
//  Copyright © 2023-2025 NutritionFacts.org. All rights reserved.
//
//swiftlint:disable file_length
//swiftlint:disable type_body_length
//swiftlint:disable function_body_length

import Foundation

@MainActor
struct SQLiteConnector {
    static let shared = SQLiteConnector()
    //
    public static let sqliteFilename = "NutritionFacts_v4.sqlite3"
    public static let sqliteFilenameTmp = "NutritionFacts.tmp.sqlite3"
    /// csvExerciseGamut may differ from SettingsManager.exerciseGamut()
    var csvExerciseGamut: ExerciseGamut = .one
    /// csvUnitsType may differ from SettingsManager.unitsType()
    var csvUnitsType: UnitsType = .metric
    ///
    var dbUrl: URL
    private let sqliteDBActor = SqliteDatabaseActor.shared
    private let viewModel = SqlDailyTrackerViewModel.shared
    
    var sqliteFilenameUrl: URL {
        return URL.inDatabase(filename: SQLiteConnector.sqliteFilename)
    }
    
    var sqliteFilenameTmpUrl: URL {
        return URL.inDatabase(filename: SQLiteConnector.sqliteFilenameTmp)
    }
    
    init() {
        dbUrl = URL
            .libraryDirectory
            .appending(component: "Database", directoryHint: .isDirectory)
            .appending(component: SQLiteConnector.sqliteFilename, directoryHint: .notDirectory)
        
        // Initialize to user preferences
        csvExerciseGamut = SettingsManager.exerciseGamut()
        csvUnitsType = SettingsManager.unitsType()
    }
    
    // MARK: Advanced Utilities Connection
    
    func exportData() async {
        print("SQLiteConnector Utility exportData()")
        _ = await csvExport(marker: "DB02_Utility_Data")
    }
    
    // MARK: - Export & Import CSV Connection
    
    func csvExport(marker: String) async -> String {
        let filename = "\(marker)-\(await Date.datestampExport()).csv"
        await csvExport(filename: filename)
        
        return filename
    }
    
    func csvExport(filename: String) async {
        
        let outUrl = URL.documentsDirectory.appendingPathComponent(filename)
        var content = csvKeysHeader()
        content.append(csvUnitsHeader() + "\n")
        
        let allTrackers = await sqliteDBActor.fetchAllTrackers()
        _ = allTrackers.count // let trackerCount =
        
        for i in 0 ..< allTrackers.count {
            let tracker = allTrackers[i]
            await content.append(csvExportLine(tracker: tracker))
        }
        
        do {
            try content.write(to: outUrl, atomically: true, encoding: .utf8)
        } catch {
            print(
                "FAIL SQLiteConnector csvExport \(error) path:'\(outUrl.path)'"
            )
        }
    }
    
    private func csvExportLine(tracker: SqlDailyTracker) async -> String {
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
            str.append(",\(tracker.weightAM?.time ?? "")")
            str.append(",\(await tracker.weightAM?.lbsStr ?? "")")
            str.append(",\(tracker.weightPM?.time ?? "")")
            str.append(",\(await tracker.weightPM?.lbsStr ?? "")")
            str.append("\n")
        } else {
            str.append(",\(tracker.weightAM?.time ?? "")")
            str.append(",\(await tracker.weightAM?.kgStr ?? "")")
            str.append(",\(tracker.weightPM?.time ?? "")")
            str.append(",\(await tracker.weightPM?.kgStr ?? "")")
            str.append("\n")
        }
        
        return str
    }
    
    mutating func csvImport(filename: String) async {
        let inUrl = URL.documentsDirectory.appendingPathComponent(filename)
        await csvImport(url: inUrl)
    }
    
    mutating func csvImport(url: URL) async {
        guard let contents = try? String(contentsOf: url)  else {
            print(
                "FAIL: csvImport file not found '\(url.lastPathComponent)'"
            )
            return
        }
        let lines = contents.components(separatedBy: .newlines)
        
        guard lines.count >= 2 else {
            print("csvImport file without data")
            return
        }
        guard isValidCsvKeysHeader(lines[0]) else {
            print("FAIL: csvImport invalid keys header")
            return
        }
        
        // Accept both old [UNITS] and new [GOALS] format
        let goalsLine = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        if goalsLine.hasPrefix("[GOALS]") || goalsLine.hasPrefix("[UNITS]") {
            if isValidSetCsvUnitsHeader(goalsLine) {
                print("Goals row parsed → ExerciseGamut: \(csvExerciseGamut), Units: \(csvUnitsType)")
            } else {
                print("FAIL: Invalid goals/units row → \(goalsLine)")
                return
            }
        } else {
            // No goals row at all → use defaults and treat line 1 as first real data
            print("No goals row found → using defaults (1 unit, metric)")
            csvExerciseGamut = .one
            csvUnitsType = .metric
            
            guard let dailyTracker = csvImportLine(goalsLine) else {
                print("FAIL: 1st data row invalid (no goals row present)")
                return
            }
            await viewModel.updateDatabase(with: dailyTracker)
        }
        
        var skippedLineCount = 0
        for i in 2..<lines.count {
            if let dailyTracker = csvImportLine(lines[i]) {
                // sqliteDBActor.saveDailyTracker(tracker: dailyTracker)
                await viewModel.updateDatabase(with: dailyTracker)
            } else {
                skippedLineCount += 1
            }
        }
        
        print("csvImport skippedLineCount==\(skippedLineCount)")
        
        // Restore to user preferences
        csvExerciseGamut = SettingsManager.exerciseGamut()
        csvUnitsType = SettingsManager.unitsType()
    }
    
    private func csvImportLine(_ line: String) -> SqlDailyTracker? {
        //print("CSV LINE → \(line)")
        
        let columns = line
            .replacingOccurrences(of: " ", with: "")
            .components(separatedBy: ",")
        
        //print("COLUMNS COUNT: \(columns.count) → \(columns)")
        
        let expectedCount = 1 + DataCountType.allCases.count + 4
        guard columns.count == expectedCount else {
            //print("WARNING: Expected \(expectedCount) columns, got \(columns.count) … likely end of file is occurs only once.")
            return nil
        }
        
        let datastampKey = columns[0]
        guard let date = Date(datestampKey: datastampKey) else {
            print("FAIL: Invalid date string → '\(datastampKey)'")
            return nil
        }
        //print("DATE OK → \(date) from '\(datastampKey)'")
        
        var tracker = SqlDailyTracker(date: date)
        
        // Checkbox counts
        var index = 1
        for dataCountType in DataCountType.allCases {
            let raw = columns[index]
            guard let value = Int(raw) else {
                print("FAIL: Non-integer in \(dataCountType.headingCSV) → '\(raw)' at index \(index)")
                return nil
            }
            let record = SqlDataCountRecord(date: date, countType: dataCountType, count: value)
            tracker.itemsDict[dataCountType] = record
            //print("  \(dataCountType.headingCSV): \(value)")
            index += 1
        }
        
        // Weight columns
        let weightIndexOffset = 1 + DataCountType.allCases.count
        let amTime = columns[weightIndexOffset]
        let amValueStr = columns[weightIndexOffset + 1]
        let pmTime = columns[weightIndexOffset + 2]
        let pmValueStr = columns[weightIndexOffset + 3]
        
        //print("WEIGHTS → AM: \(amTime),\(amValueStr)  PM: \(pmTime),\(pmValueStr)")
        
        func csvWeightToKg(_ value: String) -> String? {
            guard let raw = Double(value.trimmingCharacters(in: .whitespaces)) else { return nil }
            let kg = self.csvUnitsType == .imperial ? raw / 2.204623 : raw
            return String(format: "%.1f", kg)
        }
        
        // AM Weight
        if let kgStr = csvWeightToKg(amValueStr),
           let weightAM = SqlDataWeightRecord(
            importDatestampKey: datastampKey,  // key: `yyyyMMdd` later becomes SID `yyyy-MM-dd`
            typeKey: DataWeightType.am.typeKey,
            kilograms: kgStr,
            timeHHmm: amTime
           ) {
            tracker.weightAM = weightAM
            //print("Weight AM imported & saved: \(amValueStr) → \(kgStr) kg at \(amTime)")
        } else {
            //print("Failed to import AM weight or data not present")
        }
        
        // PM Weight
        if let kgStr = csvWeightToKg(pmValueStr),
           let weightPM = SqlDataWeightRecord(
            importDatestampKey: datastampKey,  // key: `yyyyMMdd` later become SID `yyyy-MM-dd`
            typeKey: DataWeightType.pm.typeKey,
            kilograms: kgStr,
            timeHHmm: pmTime
           ) {
            tracker.weightPM = weightPM
            //print("Weight PM imported & saved: \(pmValueStr) → \(kgStr) kg at \(pmTime)")
        } else {
            //print("Failed to import PM weight or no data present")
        }
        
        //print("SUCCESS: Parsed tracker for \(date)")
        //print("csvImportLine returning tracker for \(date.formatted(date: .numeric, time: .omitted)) with weightAM: \(tracker.weightAM?.dataweight_kg ?? -999), weightPM: \(tracker.weightPM?.dataweight_kg ?? -999)")
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
        var str = "[GOALS]"
        // 100% Goals
        for dataCountType in DataCountType.allCases {
            if dataCountType == .dozeExercise {
                str.append(",\(csvExerciseGamut.int)")
            } else {
                str.append(",\(dataCountType.goalServings)")
            }
        }
        // Weight // :GTD:[GOALS]: kg|lbs
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
        // Only normalize for prefix check
        let prefixNormalized = header
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
        
        guard prefixNormalized.hasPrefix("[goals]") || prefixNormalized.hasPrefix("[units]") else {
            print("FAIL: Goals row missing [GOALS]/[UNITS] prefix")
            return false
        }
        
        // ← CRITICAL: Split the ORIGINAL header string — do NOT use normalized version!
        let columns = header.components(separatedBy: ",")
        
        guard columns.count == 41 else {
            print("FAIL: Goals row has wrong column count: \(columns.count)")
            return false
        }
        
        // dozeExercise column (index 12) contains the gamut number
        guard let gamut = ExerciseGamut(columns[12]) else {
            print("FAIL: Invalid exercise gamut value: '\(columns[12])'")
            return false
        }
        
        // Units are in columns 38 and 40 → may be "kg", "[kg]", "lbs", "[lbs]" → your init handles all!
        guard let unitsAM = UnitsType(mass: columns[38]),
              let unitsPM = UnitsType(mass: columns[40]),
              unitsAM == unitsPM else {
            print("FAIL: Invalid or mismatched weight units → AM: '\(columns[38])' PM: '\(columns[40])'")
            return false
        }
        
        csvExerciseGamut = gamut
        csvUnitsType = unitsAM
        
        // Optional: keep your strict string match if you want, but it's redundant
        // Just validate structure — safer and simpler
        print("Goals row accepted → Gamut: \(gamut), Units: \(unitsAM)")
        return true
    }
    
}

// MARK: - Export UserData
extension SQLiteConnector {
    //
    func exportDataForUser() async -> String {
        print("SQLiteConnector Utility exportDataForUser()")
        return await generateCSVContent(marker: "DB03_Utility_Data")  // Updated marker
    }
    
    func generateCSVContent(marker: String) async -> String {
        let filename = "\(marker)-\(await Date.datestampExport()).csv"
        let content = await generateCSVContent(filename: filename)
        return content  // Return content, not filename (or return both if needed)
    }
    
    // The core generator – now returns String instead of void
    func generateCSVContent(filename: String) async -> String {
        var content = csvKeysHeader()
        content.append(csvUnitsHeader() + "\n")
        
        let allTrackers = await sqliteDBActor.fetchAllTrackers()
        
        for i in 0 ..< allTrackers.count {
            let tracker = allTrackers[i]
            content.append(await csvExportLine(tracker: tracker))  // Assuming this is async; add \n if needed
        }
        
        // Optional: Log success
        print("Generated CSV content for \(filename) with \(allTrackers.count) trackers")
        
        return content
    }
    
}

// MARK: - Import SQLite

extension SQLiteConnector {
    
    /// Called when user picks a CSV file
    mutating func importCSVAndRebuildDatabase(from csvURL: URL) async throws {
        // 1. Run your existing CSV → in-memory model logic
        await csvImport(url: csvURL)          // ← YOUR ORIGINAL CODE
        
        // 2. Close current DB
        await sqliteDBActor.close()
        
        // 3. Delete the old physical .sqlite3 file
        let finalURL = sqliteFilenameUrl
        try? FileManager.default.removeItem(at: finalURL)
        
        // 4. Force actor to reopen → it will create fresh DB + tables
        try await sqliteDBActor.setup()           // this runs CREATE TABLE etc.
        
        print("CSV imported → fresh SQLite database rebuilt")
    }
}

extension SQLiteConnector {
    /// Public non-mutating entry point for UI to call
    func performCSVImportAndRebuild(from url: URL) async throws {
        // Create a temporary mutable copy just for the import
        var temp = self                     // copy the whole struct (it's lightweight)
        await temp.csvImport(url: url)  // now safe to call mutating
        
        // After successful import, close old DB and reopen fresh one
        await sqliteDBActor.close()
        try await sqliteDBActor.setup()     // creates fresh DB + tables
    }
}
