//
//  URL.swift
//  DailyDozen
//
//  Copyright © 2017-2025 NutritionFacts.org. All rights reserved.
//

import Foundation

extension URL {
    
    /// - Returns: `Library/Database/` directory URL
    static func inDatabase() -> URL {
        return URL.libraryDirectory
            .appendingPathComponent("Database", isDirectory: true)
    }
    
    /// - Parameter filename: A file name.
    /// - Returns: `Library/Database/filename` URL
    static func inDatabase(filename: String) -> URL {
        return URL.inDatabase()
            .appendingPathComponent(filename, isDirectory: false)
    }
    
}
