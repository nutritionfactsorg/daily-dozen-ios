//
//  URL.swift
//  SqliteMigrateLegacy12
//
//  Copyright © 2023 NutritionFacts.org. All rights reserved.
//

import Foundation

extension URL {

    /// - Returns: `Documents/` directory URL
    static func inDocuments() -> URL {
        let fm = FileManager.default
        let urlList = fm.urls(for: .documentDirectory, in: .userDomainMask)
        return urlList[0]
    }
    
    /// - Parameter filename: A file name.
    /// - Returns: `Documents/filename` URL
    static func inDocuments(filename: String) -> URL {
        return URL.inDocuments().appendingPathComponent(filename, isDirectory: false)
    }
    
    /// - Returns: `Library/` directory URL
    static func inLibrary() -> URL {
        let fm = FileManager.default
        let urlList = fm.urls(for: .libraryDirectory, in: .userDomainMask)
        return urlList[0]
    }

    /// - Parameter filename: A file name.
    /// - Returns: `Library/filename` URL
    static func inLibrary(filename: String) -> URL {
        return URL.inLibrary().appendingPathComponent(filename, isDirectory: false)
    }

    /// - Returns: `Library/Database/` directory URL
    static func inDatabase() -> URL {
        let fm = FileManager.default
        let urlList = fm.urls(for: .libraryDirectory, in: .userDomainMask)
        let url = urlList[0].appendingPathComponent("Database", isDirectory: true)
        return url
    }

    /// - Parameter filename: A file name.
    /// - Returns: `Library/Database/filename` URL
    static func inDatabase(filename: String) -> URL {
        return URL.inDatabase().appendingPathComponent(filename, isDirectory: false)
    }
    
    /// - Returns: `Library/Backup/` directory URL
    static func inBackup() -> URL {
        let fm = FileManager.default
        let urlList = fm.urls(for: .libraryDirectory, in: .userDomainMask)
        let url = urlList[0].appendingPathComponent("Backup", isDirectory: true)
        return url
    }

    /// - Parameter filename: A file name.
    /// - Returns: `Library/Backup/filename` URL
    static func inBackup(filename: String) -> URL {
        return URL.inBackup().appendingPathComponent(filename, isDirectory: false)
    }

}
