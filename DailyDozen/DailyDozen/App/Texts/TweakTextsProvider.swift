//
//  TweakTextsProvider.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import Foundation

class TweakTextsProvider {
    
    static let shared: TweakTextsProvider = {
        let decoder = JSONDecoder() 
        guard 
            let path = Bundle.main.path(forResource: "TweakDetailData", ofType: "json"),
            let jsonString = try? String(contentsOfFile: path),
            let jsonData = jsonString.data(using: .utf8),
            let info = try? decoder.decode(TweakDetailInfo.self, from: jsonData)
            else { 
                fatalError("FAIL TweakTextsProvider did not load 'TweakDetailData.json'") 
        }
        return  TweakTextsProvider(info: info)
    }()
    
    private let info: TweakDetailInfo
    
    init(info: TweakDetailInfo) {
        self.info = info
    }
    
    /// Loads static texts for the current item.
    ///
    /// - Parameter itemName: The current item name.
    /// - Returns: A detail view model for static texts.
    func getDetails(itemTypeKey: String) -> TweakDetailViewModel {
        guard 
            let itemInfo = info.itemsDict[itemTypeKey] 
            else { fatalError("Tweak getTopic(\(itemTypeKey)) Item not found.") }
        return TweakDetailViewModel(itemTypeKey: itemTypeKey, info: itemInfo)
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
            else { fatalError("Tweak getTopic(\(itemTypeKey)) Item not found.") }
        return item.topic
    }
    
    /// Use: do not show toggle button if imperial and metric have the same text.
    func isMetricTxtEqualToImperialTxt(itemTypeKey: String) -> Bool {
        guard 
            let item = info.itemsDict[itemTypeKey] 
            else { fatalError("Tweak getTopic(\(itemTypeKey)) Item not found.") }
        return item.activity.imperial == item.activity.metric
    }
    
}
