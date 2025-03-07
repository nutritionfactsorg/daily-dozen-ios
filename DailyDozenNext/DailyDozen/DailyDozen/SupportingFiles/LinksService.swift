//
//  LinksService.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import Foundation

class LinksService {
    
//    private struct Strings {
//        static let baseURL = URL(string: "https://nutritionfacts.org")
//    }
    let baseURL =  URL(string: "https://nutritionfacts.org")

    var siteMain: URL {
        return baseURL ?? URL(string: "https://nutritionfacts.org")! //!!!MEC::  Is this even needed?  If so, try catch
    }
    
    //TBDz remove optionals
    func link(menu: String) -> URL {
        return (baseURL?.appendingPathComponent(menu))!  
    }
    
    // Returns the shared LinksService object.
    //TBDz shared might be a candidate for environment
    static let shared = LinksService()
//        guard let path = Bundle.main.path(
//            forResource: "LinkSettings",
//            ofType: "plist") else {
//                fatalError("There should be a settings file")
//        }
//
//        guard let dictionary = NSDictionary(contentsOfFile: path) else {
//            fatalError("There should be a settings dictionary")
//        }
//
//        guard let urlString = dictionary[Strings.baseURL] as? String,
//            let url = URL(string: urlString) else {
//                fatalError("There should be a base URL")
//        }
      //  let url = URL(string: "https://nutritionfacts.org/")! // :REVIEW:

//        return LinksService(url)
//    }()
    
    // MARK: - Inits
//    init(url: URL) {
//       baseURL = url
//    }
    init() {}
//    private init() {
//        
//    }
    /// Returns a url for the current topic.
    ///
    /// - Parameter topic: The current topic.
    /// - Returns: A url.
    func link(topic: String) -> URL {
        return baseURL!.appendingPathComponent(topic)  //NYI guard to prevent optional
    }
    /// Returns a url for the current menu item.
    ///
    /// - Parameter menu: The current menu item.
    /// - Returns: A url.
//    func link(menu: String) -> URL {
//        return baseURL.appendingPathComponent(menu)
//    }
    
}
