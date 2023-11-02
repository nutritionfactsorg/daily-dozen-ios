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
    init(newThread: Bool = false) {
        if newThread {
            realmDb = RealmProvider()
        } else {
            realmDb = RealmProvider.primary
        }
    }
    
    init(fileURL: URL) {
        realmDb = RealmProvider(fileURL: fileURL)
    }
    
    func csvExport(marker: String, activity: ActivityProgress? = nil) -> String {
        let filename = "\(marker)-\(Date.datestampExport()).csv"
        csvExport(filename: filename, activity: activity)
        return filename
    }
    
    func csvExport(filename: String, activity: ActivityProgress? = nil) {
        let outUrl = URL.inDocuments().appendingPathComponent(filename)
        var content = RealmManager.csvHeader
        content.append(RealmManager.csvHeaderLine2)
        
        let allTrackers = realmDb.getDailyTrackers(activity: activity)
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
                "FAIL RealmManager csvImport file not found '\(url.lastPathComponent)'"
            )
            return
        }
        let lines = contents.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            logit.error(
                "FAIL RealmManager csvImport CSV has less that 2 lines"
            )
            return
        }
        
        if isValidCsvHeader(lines[0]) {
            
            if lines.count >= 2 {
                if lines[1].hasPrefix("(GOAL)") {
                    // :NYI: check/set basis for execercise units, weight kg/lbs
                } else {
                    if let dailyTracker = csvProcess(line: lines[1]) {
                        realmDb.saveDailyTracker(tracker: dailyTracker)
                    }
                }
            }
            
            for i in 2..<lines.count {
                if let dailyTracker = csvProcess(line: lines[i]) {
                    realmDb.saveDailyTracker(tracker: dailyTracker)
                }
            }
        } else {
            logit.error(
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
                logit.error(
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
            logit.error(
                "FAIL RealmManager csvExport \(error) path:'\(outUrl.path)'"
            )
        }
    }
    
}
