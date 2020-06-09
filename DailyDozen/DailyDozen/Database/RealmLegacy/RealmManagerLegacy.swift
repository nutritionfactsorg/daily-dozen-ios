//
//  RealmManagerLegacy.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation

class RealmManagerLegacy {
    
    let realmDb: RealmProviderLegacy
    
    init(fileUrl: URL) {
        realmDb = RealmProviderLegacy(fileURL: fileUrl)
    }
    
    func csvExport() -> String {
        let filename = "\(Date.datestampNow())_export_legacy.csv"
        csvExport(filename: filename)
        return filename
    }
    
    func csvExport(filename: String) {
        let outUrl = URL.inDocuments().appendingPathComponent(filename)
        var content = RealmManagerLegacy.csvHeader
        
        let allDozes = realmDb.getDozesLegacy()
        for doze in allDozes {
            content.append(csvExportLine(doze: doze))
        }
        
        do {
            try content.write(to: outUrl, atomically: true, encoding: .utf8)
        } catch {
            LogService.shared.error(
                "FAIL RealmManagerLegacy csvExport \(error) path:'\(outUrl.path)'"
            )
        }
    }
    
    static let csvHeader = "Date,"
        .appending("Beans,")
        .appending("Berries,")
        .appending("Other Fruits,")
        .appending("Cruciferous Vegetables,")
        .appending("Greens,")
        .appending("Other Vegetables,")
        .appending("Flaxseeds,")
        .appending("Nuts and Seeds,")
        .appending("Herbs and Spices,")
        .appending("Whole Grains,")
        .appending("Beverages,")
        .appending("Exercise,")
        .appending("Vitamin B12,")
        .appending("Vitamin D\n")
    
    private func csvExportLine(doze: Doze) -> String {
        var str = "\(doze.date.datestampKey)"
        
        for item in doze.items {
            var stateCountPerItem = 0
            for state in item.states where state {
                stateCountPerItem += 1
            }
            str.append(",\(stateCountPerItem)")
        }
        str.append("\n")
        
        return str
    }
    
}
