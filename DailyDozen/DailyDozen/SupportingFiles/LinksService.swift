//
//  LinksService.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import Foundation

@MainActor
class LinksService {
    static let shared = LinksService()

    let baseURL =  URL(string: "https://nutritionfacts.org")!
    
    var siteMain: URL {
        baseURL
    }
    
    func link(menu: String) -> URL {
        return (baseURL.appendingPathComponent(menu))
    }
    
    // MARK: - Inits

    init() {}

    /// Returns a url for the current topic.
    ///
    /// - Parameter topic: The current topic.
    /// - Returns: A url.
    func link(topic: String) -> URL {
        return baseURL.appendingPathComponent(topic)  //TBDz NYI guard to prevent optional
    }
        
}
