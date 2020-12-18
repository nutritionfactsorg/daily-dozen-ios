//
//  ChartDataEntry.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation
import Charts

extension ChartDataEntry {
    func toStringXY() -> String {
        return String(format: "%.2f\t%.2f", self.x, self.y)
    }
}
