//
//  LinksService.swift
//  NFTest
//
//  Created by mc on 1/3/25.
//

import Foundation

class LinksService {
    private let baseURL =  URL(string: "https://nutritionfacts.org")

    var siteMain: URL {
        return baseURL ?? URL(string: "https://nutritionfacts.org")! //!!!MEC::  Is this even needed?  If so, try catch
    }
    
    func link(menu: String) -> URL {
        return (baseURL?.appendingPathComponent(menu))!  
    }
}
