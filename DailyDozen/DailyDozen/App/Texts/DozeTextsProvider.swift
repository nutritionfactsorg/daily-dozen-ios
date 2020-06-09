//
//  DozeTextsProvider.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import Foundation

class DozeTextsProvider {
    
    static let shared: DozeTextsProvider = {
        let decoder = JSONDecoder() 
        guard 
            let path = Bundle.main.path(forResource: "DozeDetailData", ofType: "json"),
            let jsonString = try? String(contentsOfFile: path),
            let jsonData = jsonString.data(using: .utf8),
            let info = try? decoder.decode(DozeDetailInfo.self, from: jsonData)
            else { 
                fatalError("FAIL DozeTextsProvider did not load 'DozeDetailData.json'") 
        }
        return  DozeTextsProvider(info: info)
    }()
    
    private let info: DozeDetailInfo
    
    init(info: DozeDetailInfo) {
        self.info = info
    }
    
    /// Loads static texts for the current item.
    ///
    /// - Parameter itemName: The current item name.
    /// - Returns: A detail view model for static texts.
    func getDetails(itemTypeKey: String) -> DozeDetailViewModel {
        guard 
            let itemInfo = info.itemsDict[itemTypeKey] 
            else { fatalError("DozeTextsProvider getDetails(\(itemTypeKey)) Item not found.") }
        return DozeDetailViewModel(itemTypeKey: itemTypeKey, info: itemInfo)
    }
    
    /// Returns the URL topic for the current item name.
    ///
    /// Use:
    ///
    /// ```
    /// https://nutritionfacts.org/topics/TOPIC/
    /// ```
    ///
    /// - Parameter itemName: The current item name.
    /// - Returns: URL path TOPIC component.
    func getTopic(itemTypeKey: String) -> String {
        guard 
            let item = info.itemsDict[itemTypeKey] 
            else { fatalError("DozeTextsProvider getTopic(\(itemTypeKey)) Item not found.") }
        return item.topic
    }
    
}
