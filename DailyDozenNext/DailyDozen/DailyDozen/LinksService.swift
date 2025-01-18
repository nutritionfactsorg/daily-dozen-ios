//
//  LinksService.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import Foundation

class LinksService {
    private let baseURL =  URL(string: "https://nutritionfacts.org")

    var siteMain: URL {
        return baseURL ?? URL(string: "https://nutritionfacts.org")! // :GTD:!!!:  Is this even needed?  If so, try catch
    }
    
    func link(menu: String) -> URL {
        return (baseURL?.appendingPathComponent(menu))!  
    }
}
