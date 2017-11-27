//
//  Date.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 09.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation

extension Date {

    /// Returns a short style sting for the date.
    var shortDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "en_GB")
        return formatter.string(from: self)
    }

    /// Returns a day name from the date.
    var dayName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
        return dateFormatter.string(from: self)
    }

    /// Returns a day int for the date.
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }

    /// Returns a date string from the date.
    ///
    /// - Parameter style: a dateFormatter style (default is .medium).
    /// - Returns: A date string.
    func dateString(for style: DateFormatter.Style = .medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
}
