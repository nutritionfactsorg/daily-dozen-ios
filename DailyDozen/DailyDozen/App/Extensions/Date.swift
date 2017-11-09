//
//  Date.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 09.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation

extension Date {

    /// Returns a short style sting for the current date.
    var shortDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "en_GB")
        return formatter.string(from: self)
    }
}
