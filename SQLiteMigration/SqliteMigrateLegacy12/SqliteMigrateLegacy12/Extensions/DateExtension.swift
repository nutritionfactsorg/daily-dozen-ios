//
//  DateExtensions.swift
//  SQLiteApi/Extensions
//

import Foundation

extension Date {
    
    init?(datestampKey: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        if let date = dateFormatter.date(from: datestampKey) {
            self = date
            return
        } else {
            return nil
        }
    }
    
    var datestampHHmm: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    /// Return yyyyMMdd based on the current locale.
    var datestampKey: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: self)
    }
    
    /// Returns a day int for the date.
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

}
