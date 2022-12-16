//
//  RealmManager.swift
//  DatabaseMigration
//
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation

class RealmManager {
    
    let realmDb: RealmProvider
    
    /// 
    init() {
        realmDb = RealmProvider()
    }
    
    init(fileURL: URL) {
        realmDb = RealmProvider(fileURL: fileURL)
    }
    
    func csvExport(marker: String) -> String {
        let filename = "\(Date.datestampNow())_\(marker).csv"
        csvExport(filename: filename)
        return filename
    }
    
    func csvExport(filename: String) {
        let outUrl = URL.inDocuments().appendingPathComponent(filename)
        var content = RealmManager.csvHeader

        let allTrackers = realmDb.getDailyTrackers()
        for tracker in allTrackers {
            content.append(csvExportLine(tracker: tracker))
        }
        
        do {
            try content.write(to: outUrl, atomically: true, encoding: .utf8)
        } catch {
            LogService.shared.error(
                "FAIL RealmManager csvExport \(error) path:'\(outUrl.path)'"
            )
        }
    }
    
    private func csvExportLine(tracker: DailyTracker) -> String {
        var str = ""
        str.append("\(tracker.date.datestampKey)")
        
        for dataCountType in DataCountType.allCases {
            if let dataCountRecord = tracker.itemsDict[dataCountType] {
                str.append(",\(dataCountRecord.count)")
            } else {
                str.append(",0")
            }
        }
        // Weight
        str.append(",\(tracker.weightAM.time)")
        str.append(",\(tracker.weightAM.kg)")
        str.append(",\(tracker.weightPM.time)")
        str.append(",\(tracker.weightPM.kg)")
        str.append("\n")

        return str
    }
    
    func csvImport(filename: String) {
        let inUrl = URL.inDocuments().appendingPathComponent(filename)
        csvImport(url: inUrl)
    }
    
    func csvImport(url: URL) {
        guard let contents = try? String(contentsOf: url)  else {
            LogService.shared.error(
                "FAIL RealmManager csvImport file not found '\(url.lastPathComponent)'"
            )
            return
        }
        let lines = contents.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            LogService.shared.error(
                "FAIL RealmManager csvImport CSV has less that 2 lines"
            )
            return
        }
        
        if isValidCsvHeader(lines[0]) {
            for i in 1..<lines.count {
                if let dailyTracker = csvProcess(line: lines[i]) {
                    realmDb.saveDailyTracker(tracker: dailyTracker)
                }
            }
        } else if isValidCsvHeaderLegacy(lines[0]) {
            for i in 1..<lines.count {
                if let dailyTracker = csvProcessLegacy(line: lines[i]) {
                    realmDb.saveDailyTracker(tracker: dailyTracker)
                }
            }
        } else {
            LogService.shared.error(
                "FAIL RealmManager csvImport CSV does not contain a valid header line"
            )
            return
        }
        
    }

    private func isValidCsvHeader(_ header: String) -> Bool {
        let currentHeaderFiltered = header
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
            .appending("\n")

        let legacyHeader = RealmManager.csvHeader
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
        
        return currentHeaderFiltered == legacyHeader
    }

    private func isValidCsvHeaderLegacy(_ header: String) -> Bool {
        let currentHeaderFiltered = header
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
            .appending("\n")
        
        let legacyHeader = RealmManagerLegacy.csvHeader
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
        
        return currentHeaderFiltered == legacyHeader
    }
    
    private func csvProcess(line: String) -> DailyTracker? {
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
        var tracker = DailyTracker(date: date)
        
        var index = 1
        for dataCountType in DataCountType.allCases {
            if let value = Int(columns[index]) {
                let dataCountRecord = DataCountRecord(
                date: date,
                countType: dataCountType,
                count: value
                )
                tracker.itemsDict[dataCountType] = dataCountRecord
            } else {
                LogService.shared.error(
                    "FAIL RealmManager csvProcess \(index) in \(line)"
                )
            }
            index += 1
        }
        
        let weightIndexOffset = 1 + DataCountType.allCases.count
        let weightAM = DataWeightRecord(
            datestampKey: datastampKey,
            typeKey: DataWeightType.am.typeKey,
            kilograms: columns[weightIndexOffset],
            timeHHmm: columns[weightIndexOffset+1]
        )
        if let weight = weightAM {
            tracker.weightAM = weight
        }
        let weightPM = DataWeightRecord(
            datestampKey: datastampKey,
            typeKey: DataWeightType.pm.typeKey,
            kilograms: columns[weightIndexOffset+2],
            timeHHmm: columns[weightIndexOffset+3]
        )
        if let weight = weightPM {
            tracker.weightPM = weight
        }

        return tracker
    }
    
    private func csvProcessLegacy(line: String) -> DailyTracker? {
        let columns = line
            .replacingOccurrences(of: " ", with: "")
            .components(separatedBy: ",")
        // Expected count: 1x date plus 14x legacy fields
        guard columns.count == 1 + 14 else {
            if columns.count > 1 { //  line with at least one `,`
                LogService.shared.warning(
                    "WARN RealmManager csvProcess  incorrect column count (\(columns.count)) '\(line)'"
                )
            }
            return nil
        }
        
        let datastampKey = columns[0]
        guard let date = Date(datestampKey: datastampKey) else {
            return nil
        }
        let tracker = DailyTracker(date: date)

        tracker.setCount(typeKey: .dozeBeans, countText: columns[1])
        tracker.setCount(typeKey: .dozeBerries, countText: columns[2])
        tracker.setCount(typeKey: .dozeFruitsOther, countText: columns[3])
        tracker.setCount(typeKey: .dozeVegetablesCruciferous, countText: columns[4])
        tracker.setCount(typeKey: .dozeGreens, countText: columns[5])
        tracker.setCount(typeKey: .dozeVegetablesOther, countText: columns[6])
        tracker.setCount(typeKey: .dozeFlaxseeds, countText: columns[7])
        tracker.setCount(typeKey: .dozeNuts, countText: columns[8])
        tracker.setCount(typeKey: .dozeSpices, countText: columns[9])
        tracker.setCount(typeKey: .dozeWholeGrains, countText: columns[10])
        tracker.setCount(typeKey: .dozeBeverages, countText: columns[11])
        tracker.setCount(typeKey: .dozeExercise, countText: columns[12])
        tracker.setCount(typeKey: .otherVitaminB12, countText: columns[13])
        tracker.setCount(typeKey: .otherVitaminD, countText: columns[14])

        return tracker
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
    
    // MARK: - Weight Only
    
    func csvExportWeight(marker: String) -> String {
        let filename = "\(Date.datestampNow())_\(marker).csv"
        csvExportWeight(filename: filename)
        return filename
    }
    
    func csvExportWeight(filename: String) {
        let outUrl = URL.inDocuments().appendingPathComponent(filename)
        var content = "DB_PID,time,kg,lbs\n"

        let allWeights = realmDb.getDailyWeightsArray()        
        for record in allWeights {
            content.append("\(record.pid),\(record.time),\(record.kgStr),\(record.lbsStr)\n")
        }
        
        do {
            try content.write(to: outUrl, atomically: true, encoding: .utf8)
        } catch {
            LogService.shared.error(
                "FAIL RealmManager csvExport \(error) path:'\(outUrl.path)'"
            )
        }
    }
    
}
