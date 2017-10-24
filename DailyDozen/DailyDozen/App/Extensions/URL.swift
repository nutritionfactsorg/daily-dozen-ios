//
//  URL.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 24.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation

extension URL {

    /// Returns a file URL in the documents directory.
    ///
    /// - Parameter file: A file name.
    /// - Returns: A file URL in the documents directory.
    static func inDocuments(for file: String) -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0].appendingPathComponent(file)
    }
}
