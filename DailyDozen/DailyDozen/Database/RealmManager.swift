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
        realmDb = RealmProvider.primary
    }
    
    init(fileURL: URL) {
        realmDb = RealmProvider(fileURL: fileURL)
    }
    
    func csvExport(marker: String) -> String {
        let filename = "\(marker)-\(Date.datestampExport()).csv"
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
    
    private func csvExportLine(tracker: RealmDailyTracker) -> String {
        var str = ""
        str.append("\(tracker.date.datestampKey)")
        
        for dataCountType in DataCountType.allCases {
            if let realmDataCountRecord = tracker.itemsDict[dataCountType] {
                str.append(",\(realmDataCountRecord.count)")
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
        } else {
            LogService.shared.error(
                "FAIL RealmManager csvImport CSV does not contain a valid header line"
            )
            return
        }
        
    }
    
    private func isValidCsvHeader(_ header: String) -> Bool {
        let currentHeaderNormalized = header
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
            .appending("\n")
        
        let referenceHeaderNormalize = RealmManager.csvHeader
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
        
        return currentHeaderNormalized == referenceHeaderNormalize
    }
    
    private func csvProcess(line: String) -> RealmDailyTracker? {
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
        var tracker = RealmDailyTracker(date: date)
        
        var index = 1
        for dataCountType in DataCountType.allCases {
            if let value = Int(columns[index]) {
                let realmDataCountRecord = RealmDataCountRecord(
                    date: date,
                    countType: dataCountType,
                    count: value
                )
                tracker.itemsDict[dataCountType] = realmDataCountRecord
            } else {
                LogService.shared.error(
                    "FAIL RealmManager csvProcess \(index) in \(line)"
                )
            }
            index += 1
        }
        
        let weightIndexOffset = 1 + DataCountType.allCases.count
        let weightAM = RealmDataWeightRecord(
            datestampKey: datastampKey,
            typeKey: DataWeightType.am.typeKey,
            kilograms: columns[weightIndexOffset],
            timeHHmm: columns[weightIndexOffset+1]
        )
        if let weight = weightAM {
            tracker.weightAM = weight
        }
        let weightPM = RealmDataWeightRecord(
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
