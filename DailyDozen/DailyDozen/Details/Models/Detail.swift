//
//  Detail.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 07.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation

struct Detail {

    // MARK: - Properties
    var metricSizes: [String]
    var imperialSizes: [String]
    var types: [[String: String]]

    // MARK: - Inits
    init(metricSizes: [String], imperialSizes: [String], types: [[String: String]]) {
        self.metricSizes = metricSizes
        self.imperialSizes = imperialSizes
        self.types = types
    }
}
