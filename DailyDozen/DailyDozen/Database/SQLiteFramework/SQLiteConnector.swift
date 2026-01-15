//
//  SQLiteConnector.swift
//  SQLiteFramework
//
//  Copyright © 2023-2026 NutritionFacts.org. All rights reserved.
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
    
    mutating func csvImport(
        filename: String,
        onProgress: @escaping @Sendable (Double) async -> Void = { _ in }
    ) async {
        let inUrl = URL.documentsDirectory.appendingPathComponent(filename)
        await csvImport(url: inUrl, onProgress: onProgress)
    }
    
    mutating func csvImport(
        url: URL,
        onProgress: @escaping @Sendable (Double) async -> Void = { _ in }
    ) async {
        guard let contents = try? String(contentsOf: url)  else {
            print(
                "•ERROR•CSV•FAIL• csvImport file not found '\(url.lastPathComponent)'"
            )
            return
        }
        let lines = contents.components(separatedBy: .newlines)
        let totalLines = lines.count
        
        guard totalLines >= 2 else {
            print("•WARN•CSV• csvImport file without data")
            return
        }
        guard isValidCsvKeysHeader(lines[0]) else {
            print("•ERROR•CSV•FAIL• csvImport invalid keys header")
            return
        }
        
        // Progress setup
        let step = 5                      // 5 percent progress steps
        var lastReportedPercent = 7       // Start checking from just below 10 percent progress
        await onProgress(0.07)            // initial CSV import feedback
        
        // Accept both old [UNITS] and new [GOALS] format line at index 1 (second row)
        let lineAtIdx1 = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        if lineAtIdx1.lowercased().hasPrefix("[goals]") ||
            lineAtIdx1.lowercased().hasPrefix("[units]") {
            if isValidSetCsvUnitsHeader(lineAtIdx1) {
                print("•INFO•CSV• Goals row parsed → ExerciseGamut: \(csvExerciseGamut), Units: \(csvUnitsType)")
            } else {
                print("•ERROR•CSV•FAIL• Invalid goals/units row → \(lineAtIdx1)")
                return
            }
        } else {
            // No goals row at all → use defaults and treat `lineAtIdx1` as first real data
            print("•INFO•CSV• No goals header row → using defaults (exercise goal: 1, metric)")
            csvExerciseGamut = .one // exercise goal is set to 1
            csvUnitsType = .metric
            
            guard let dailyTracker = csvImportLine(lineAtIdx1) else {
                print("•ERROR•CSV•FAIL• 1st data row invalid (no goals row present)")
                return
            }
            await viewModel.updateDatabase(with: dailyTracker)
        }
        
        var skippedLineCount = 0
        for rowIdx in 2..<totalLines {
            if let dailyTracker = csvImportLine(lines[rowIdx]) {
                await viewModel.updateDatabase(with: dailyTracker)
            } else {
                skippedLineCount += 1
            }
            
            // Update Progress
            // Integer percentage (rounded down)
            let percent = ((rowIdx + 1) * 100) / totalLines
            // Snap to next 5% boundary only when crossed
            let snapped = (percent / step) * step
            if snapped >= 10 && snapped <= 90 && snapped > lastReportedPercent {
                lastReportedPercent = snapped
                await onProgress(Double(snapped) / 100.0)
            }
        }
        // End CSV import phase at 95% percent profile
        await onProgress(0.95)
        
        print("•INFO•CSV• csvImport skippedLineCount==\(skippedLineCount)")
        
        // Restore to user preferences
        csvExerciseGamut = SettingsManager.exerciseGamut()
        csvUnitsType = SettingsManager.unitsType()
    }
    
    private func csvImportLine(_ line: String) -> SqlDailyTracker? {
        //print("•TRACE•CSV• LINE → \(line)")
        
        let columns = line
            .replacingOccurrences(of: " ", with: "")
            .components(separatedBy: ",")
        
        //print("•TRACE•CSV• columns.count: \(columns.count) → values: \(columns)")
        // Note: column count = 1 + n + 4 = date(1) + checkboxes(n) + weight(4)
        let expectedCount = 1 + DataCountType.allCases.count + 4
        guard columns.count == expectedCount else {
            print("•WARN•CSV• Expected \(expectedCount) columns, got \(columns.count) … likely end of file if occurs only once.")
            return nil
        }
        // --- Process Datestamp Column ---
        let datestampKey = columns[0]
        guard let date = Date(datestampKey: datestampKey) else {
            print("•ERROR•CSV•FAIL• Invalid datestampKey string → '\(datestampKey)'")
            return nil
        }
        //print("•TRACE•CSV• DATE OK → \(date) from '\(datastampKey)'")
        
        var tracker = SqlDailyTracker(date: date)
        
        // --- Process Checkbox Datacount Columns ---
        var index = 1
        for dataCountType in DataCountType.allCases {
            let raw = columns[index]
            guard let value = Int(raw) else {
                let typeHeading = dataCountType.headingCSV
                print("•ERROR•CSV•FAIL• Non-integer \(typeHeading):'\(raw)' @\(index) in \(line)")
                return nil
            }
            let record = SqlDataCountRecord(date: date, countType: dataCountType, count: value)
            tracker.itemsDict[dataCountType] = record
            //print("•VERBOSE•CSV• \(dataCountType.headingCSV): \(value)")
            index += 1
        }
        
        // --- Process Weight Columns ---
        let weightIdxOffset = 1 + DataCountType.allCases.count
        let amTime = columns[weightIdxOffset]
        let amValueStr = columns[weightIdxOffset + 1]
        let pmTime = columns[weightIdxOffset + 2]
        let pmValueStr = columns[weightIdxOffset + 3]
        
        //print("WEIGHTS → AM: \(amTime),\(amValueStr)  PM: \(pmTime),\(pmValueStr)")
        
        func csvWeightToKg(_ value: String) -> String? {
            guard let raw = Double(value.trimmingCharacters(in: .whitespaces)) else { return nil }
            let kg = self.csvUnitsType == .imperial ? raw / 2.205 : raw
            return String(format: "%.1f", kg)
        }
        
        // Process AM Weight
        if let kgStr = csvWeightToKg(amValueStr),
           let weightAM = SqlDataWeightRecord(
            importDatestampKey: datestampKey,  // key: `yyyyMMdd` later becomes SID `yyyy-MM-dd`
            typeKey: DataWeightType.am.typeKey,
            kilograms: kgStr,
            timeHHmm: amTime
           ) {
            tracker.weightAM = weightAM
            //print("•VERBOSE•CSV• Weight AM imported & saved: \(amValueStr) → \(kgStr) kg at \(amTime)")
        } else {
            //print("•VERBOSE•CSV• Failed to import AM weight or data not present")
        }
        
        // Process PM Weight
        if let kgStr = csvWeightToKg(pmValueStr),
           let weightPM = SqlDataWeightRecord(
            importDatestampKey: datestampKey,  // key: `yyyyMMdd` later become SID `yyyy-MM-dd`
            typeKey: DataWeightType.pm.typeKey,
            kilograms: kgStr,
            timeHHmm: pmTime
           ) {
            tracker.weightPM = weightPM
            //print("•VERBOSE•CSV• Weight PM imported & saved: \(pmValueStr) → \(kgStr) kg at \(pmTime)")
        } else {
            //print("•VERBOSE•CSV• Failed to import PM weight or no data present")
        }
        
        //print("•TRACE•CSV•PASS• Parsed tracker for \(date)")
        //print("•VERBOSE•CSV• csvImportLine returning tracker for \(date.formatted(date: .numeric, time: .omitted)) with weightAM: \(tracker.weightAM?.dataweight_kg ?? -999), weightPM: \(tracker.weightPM?.dataweight_kg ?? -999)")
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
        // Weight // •GTD•[GOALS]• kg|lbs
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
            print("•ERROR•CSV•FAIL• Goals row missing [GOALS]/[UNITS] prefix")
            return false
        }
        
        // ← CRITICAL: Split the ORIGINAL header string — do NOT use normalized version!
        let columns = header.components(separatedBy: ",")
        
        guard columns.count == 41 else {
            print("•ERROR•CSV•FAIL• Goals row has wrong column count: \(columns.count)")
            return false
        }
        
        // dozeExercise column (index 12) contains the gamut number
        guard let gamut = ExerciseGamut(columns[12]) else {
            print("•ERROR•CSV•FAIL• Invalid exercise gamut value: '\(columns[12])'")
            return false
        }
        
        // Units are in columns 38 and 40 → may be "kg", "[kg]", "lbs", "[lbs]" → your init handles all!
        guard let unitsAM = UnitsType(mass: columns[38]),
              let unitsPM = UnitsType(mass: columns[40]),
              unitsAM == unitsPM else {
            print("•ERROR•CSV•FAIL• Invalid or mismatched weight units → AM: '\(columns[38])' PM: '\(columns[40])'")
            return false
        }
        
        csvExerciseGamut = gamut
        csvUnitsType = unitsAM
        
        // Optional: keep your strict string match if you want, but it's redundant
        // Just validate structure — safer and simpler
        print("Goals row accepted → Gamut: \(gamut), Units: \(unitsAM)")
        return true
    }
    
    // MARK: - Bulk
    
    mutating func csvBulkImport(
        url: URL,
        onProgress: @escaping @Sendable (Double) async -> Void = { _ in }
    ) async {
        guard let contents = try? String(contentsOf: url) else {
            print("•ERROR•CSV•FAIL• csvBulkImport file not found '\(url.lastPathComponent)'")
            return
        }
        
        let lines = contents.components(separatedBy: .newlines)
        let totalLines = lines.count
        
        guard totalLines >= 2 else {
            print("•WARN•CSV• csvBulkImport file without data")
            return
        }
        
        guard isValidCsvKeysHeader(lines[0]) else {
            print("•ERROR•CSV•FAIL• csvBulkImport invalid keys header")
            return
        }
        
        // Progress setup (parsing ≈ 0.0–0.9, bulk ≈ 0.9–1.0)
        let parsingEnd: Double = 0.9
        let step = 5
        var lastReportedPercent = 0
        await onProgress(0.05)
        
        // Handle goals/units row (index 1)
        let lineAtIdx1 = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
        var startIdx = 2
        
        if lineAtIdx1.lowercased().hasPrefix("[goals]") ||
            lineAtIdx1.lowercased().hasPrefix("[units]") {
            guard isValidSetCsvUnitsHeader(lineAtIdx1) else {
                print("•ERROR•CSV•FAIL• Invalid goals/units row → \(lineAtIdx1)")
                return
            }
            print("•INFO•CSV• Goals row parsed → ExerciseGamut: \(csvExerciseGamut), Units: \(csvUnitsType)")
        } else {
            print("•INFO•CSV• No goals header row → using defaults for import")
            csvExerciseGamut = .one
            csvUnitsType = .metric
            startIdx = 1  // treat lineAtIdx1 as first data row
        }
        
        var collectedTrackers: [SqlDailyTracker] = []
        collectedTrackers.reserveCapacity(totalLines - startIdx)
        
        var skippedLineCount = 0
        
        for rowIdx in startIdx..<totalLines {
            let line = lines[rowIdx]
            if let tracker = csvImportLine(line) {
                collectedTrackers.append(tracker)
            } else {
                skippedLineCount += 1
            }
            
            // Parsing progress (0.0 → 0.9)
            let percent = Double(rowIdx + 1 - startIdx + 1) / Double(totalLines - startIdx + 1) * parsingEnd * 100
            let snapped = (Int(percent) / step) * step
            if snapped >= 10 && snapped <= Int(parsingEnd * 100) && snapped > lastReportedPercent {
                lastReportedPercent = snapped
                await onProgress(Double(snapped) / 100.0)
            }
        }
        
        await onProgress(parsingEnd)
        print("•INFO•CSV• csvBulkImport parsed \(collectedTrackers.count) trackers, skipped \(skippedLineCount)")
        
        // Bulk insert phase (0.9 → 1.0)
        await sqliteDBActor.bulkInsert(
            trackers: collectedTrackers,
            onProgress: { bulkFraction in
                await onProgress(parsingEnd + (1.0 - parsingEnd) * bulkFraction)
            }
        )
        
        await onProgress(1.0)
        
        // Restore user preferences for future exports
        csvExerciseGamut = SettingsManager.exerciseGamut()
        csvUnitsType = SettingsManager.unitsType()
    } // csvBuldImport
    
}

// MARK: - Export UserData
extension SQLiteConnector {
    //
    func exportDataForUser() async -> String {
        print("SQLiteConnector Utility exportDataForUser()")
        return await generateCSVContent(marker: "ExportCSV")  // Updated marker
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
    /// Public non-mutating entry point for UI to call
    func performCSVImportAndRebuild(from url: URL) async throws {
        // Create a temporary mutable copy just for the import
        var temp = self // copy the whole struct (it's lightweight)
        // `temp` now safe to call mutating
        await temp.csvImport(url: url) { progress in
            await MainActor.run {
                MigrationManager.shared.migrationProgress = progress
            }
        }
        
        // After successful import, close old DB and reopen fresh one
        await sqliteDBActor.close()
        await MainActor.run {
            MigrationManager.shared.migrationProgress = 0.98
        }
        try await sqliteDBActor.setup() // creates fresh DB + tables
        // Final completion handled in MigrationManager
    }
    
    func performCSVImportAndRebuildBulk(from url: URL) async throws {
        // Create a temporary mutable copy just for the import
        var temp = self // copy the whole struct (it's lightweight)
        // `temp` now safe to call mutating
        await temp.csvBulkImport(url: url) { progress in
            await MainActor.run {
                MigrationManager.shared.migrationProgress = progress
            }
        }
        
        // After successful import, close old DB and reopen fresh one
        await sqliteDBActor.close()
        await MainActor.run {
            MigrationManager.shared.migrationProgress = 0.95 // 95 percent
        }
        try await sqliteDBActor.setup() // creates fresh DB + tables
        // Final completion handled in MigrationManager
        
        // Optional final refresh
        await viewModel.loadData()
    }
}
