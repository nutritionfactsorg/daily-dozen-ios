//
//  ScrollHelper.swift
//  DailyDozenUITests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import XCTest

struct ScrollHelper {
    // singleton
    static let shared = ScrollHelper()
    // properties
    private var _app: XCUIApplication!
    
    mutating func setApp(_ app: XCUIApplication) {
        _app = app
    }
    
    // MARK: - Access Tree 
    
    func printAccessTree(withFrames: Bool = false) {
        // accessibility hierarchy snapshot
        var str = getAccessTree(withFrames: withFrames)
        str = str.replacingOccurrences(of: "\\n", with: "\n")
        print("::APP ACCESSIBILITY HIERARCHY::\n\(str)")
    }

    func getAccessTree(withFrames: Bool = false) -> String {
        // accessibility hierarchy snapshot
        var str = _app.debugDescription

        if withFrames == false {
            // {{origin: left-upper}, {size: width-height}
            // {{0.0, 0.0}, {320.0, 568.0}}
            let regex = "\\{\\{.*\\}\\}"
            str = str.replacingOccurrences(of: regex, with: "", options: .regularExpression)
        }
        
        //             0x600003f5a840
        let regex = ", 0x[a-f0-9]+,"
        str = str.replacingOccurrences(of: regex, with: "", options: .regularExpression)
        str = str.replacingOccurrences(of: " ,", with: ",", options: .regularExpression)
        return str
    }
    
    // MARK: - Cells
    
    func getCellList() -> String {
        //           cell[0] exists
        var str = "•••••\ncell[N]:exists:frame:hittable: identifier\n"
        let cellList = _app.cells.allElementsBoundByIndex
        for idx in 0 ..< cellList.count {
            let cell = cellList[idx]
            let exists = cell.exists ? "T" : "f"
            let frame = !cell.frame.isEmpty ? "T" : "f"
            let hittable = cell.isHittable ? "T" : "f"
            str.append("cell[\(idx)] \(exists) \(frame) \(hittable) \(cell.identifier)\n")
        }
        return str
    }
    
    func printCellList() {
        print("\n\(getCellList())\n")
    }
    
}
