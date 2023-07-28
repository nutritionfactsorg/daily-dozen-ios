//
//  DateExtensions.swift
//  SQLiteApi/Extensions
//

import Foundation

extension Date {
    
    /// yyyyMMdd
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
    
    /// yyyy-MM-dd ISO 8601 String ID based on the current locale
    init?(datestampSid: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: datestampSid) {
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
    
    /// Return yyyy-MM-dd ISO 8601 String ID based on the current locale.
    var datestampSid: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
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
