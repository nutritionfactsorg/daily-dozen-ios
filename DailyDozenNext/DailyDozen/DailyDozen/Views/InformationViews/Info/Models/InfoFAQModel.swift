//
//  InfoFAQModel.swift
//  DailyDozen
//
//  Created by mc on 1/17/25.
//

import SwiftUI

struct InfoFaqModel {
    let title: String
    let details: String  //old was NSAttributedString
    var expanded: Bool
    
    init(title: String, details: String, expanded: Bool = false) {
        self.title = title
        //self.details = parseLinkedString(details)
        self.details = "Hello World"
        self.expanded = expanded
    }
//    init(title: String, details: String, expanded: Bool = false) {
//   // init(title: String, details: NSAttributedString, expanded: Bool = false) {
//        self.title = title
//        self.details = details
//        self.expanded = expanded
//    }
}
