//
//  RealmManager.swift
//  DatabaseMigration
//
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation

class RealmManager {
    
    let realmDb: RealmProvider
    let inputDirUrl: URL
    let outputDirUrl: URL
    
    init(inputDirUrl: URL, outputDirUrl: URL) {
        realmDb = RealmProvider()
        self.inputDirUrl = inputDirUrl
        self.outputDirUrl = outputDirUrl
    }
    
    func csvExport(filename: String) {
        
    }
    
    func csvImport(filename: String) {
        let inUrl = inputDirUrl.appendingPathComponent(filename)
        guard var csv = try? String(contentsOf: inUrl) else { 
            fatalError("\(filename) not found") // :!!!:NYI: proper error handling
        }
        
        csv = csv.replacingOccurrences(of: "\r", with: "")
        let lines = csv.components(separatedBy: "\n")
        //let lines = csv.split(separator: "\n")
        
        guard lines.count > 1 else {
            fatalError("\(filename) less than 2 line") // :!!!:NYI: proper error handling
        }
        
        // Deterimine data column sequence from headings
        let headingsStringList = lines[0].components(separatedBy: ",")
        var headings = [DataCountType]()
        for string in headingsStringList {
            if let headingType = DataCountType(csvHeading: string) {
                headings.append(headingType)                
            } else {
                fatalError("RealmManager csvImport() heading not found") // :!!!:NYI: proper error handling
            }
        }
        if headings.count < 2 {
            fatalError("RealmManager csvImport() headings.count < 2") // :!!!:NYI: proper error handling
        }
        //if headings[0] != .date {
        //    fatalError("RealmManager csvImport() date not found as the first column.") // :!!!:NYI: proper error handling
        //}
    
        // Process each line of data
        for i in 1..<lines.count {
            let valueStrings = lines[i].components(separatedBy: ",") 
            if headings.count != valueStrings.count {
                print("\(i-1) data lines imported") // :!!!:NYI: status number of lines completed
                return
            }
            // Date
            
            let datestamp = valueStrings[0]
            
            // 
            var counters = [DataCountRecord]()
            for j in 1..<valueStrings.count {
                let dataCountTypeKey = headings[j].typeKey()
                guard let count = Int(valueStrings[0]) else { 
                    fatalError("RealmManager csvImport() invalid count string \(i):\(j)") // :!!!:NYI: proper error handling 
                }
                if let dataCountRecord = DataCountRecord(
                    datestampKey: datestamp, 
                    typeKey: dataCountTypeKey, 
                    count: count) {
                    counters.append(dataCountRecord)
                } else {
                    print(":DEBUG: unconvertable record \(i):\(i) \(datestamp) \(dataCountTypeKey) \(count)")
                }
            }
            // Save successfully completed row of data.
            // :!!!: realmDb.saveDataCounts(counters)
        }
    }
    
}
