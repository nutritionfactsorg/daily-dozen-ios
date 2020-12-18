//
//  MenuItem.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 31.01.2018.
//  Copyright © 2018 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum MenuItem: Int {

    // MARK: - Nested
    
    /// Links: provides url path component "https://nutritionfacts.org/COMPONENT/"
    /// :NYI:ToBeLocalized: web link components
    /// EN: "https://nutritionfacts.org/donate/"
    /// ES: "https://nutritionfacts.org/es/dona-a-nutritionfacts-org/"
    private struct Links {
        static let videos = NSLocalizedString(
            "urlSegmentInfoMenu.videos",
            comment: "main info menu: videos")
        static let book = NSLocalizedString(
            "urlSegmentInfoMenu.book",
            comment: "main info menu: book")
        static let cookbook = NSLocalizedString(
            "urlSegmentInfoMenu.cookbook",
            comment: "main info menu: cookbook")
        static let diet = NSLocalizedString(
            "urlSegmentInfoMenu.diet",
            comment: "main info menu: how-not-to-diet")
        static let challenge = NSLocalizedString(
            "urlSegmentInfoMenu.challenge",
            comment: "main info menu: daily-dozen-challenge")
        static let donate = NSLocalizedString(
            "urlSegmentInfoMenu.donate",
            comment: "main info menu: donate")
        static let subscribe = NSLocalizedString(
            "urlSegmentInfoMenu.subscribe",
            comment: "main info menu: subscribe")
        static let source = NSLocalizedString(
            "urlSegmentInfoMenu.source",
            comment: "main info menu: open-source")
    }

    /// Defines item order for `InfoMenuMainTableVC`
    case videos, book, cookbook, diet, challenge, donate, subscribe, source, about

    var link: String? {
        switch self {
        case .about:
            return nil // not a URL link
        case .videos:
            return Links.videos
        case .book:
            return Links.book
        case .cookbook:
            return Links.cookbook
        case .diet:
            return Links.diet
        case .challenge:
            return Links.challenge
        case .donate:
            return Links.donate
        case .subscribe:
            return Links.subscribe
        case .source:
            return Links.source
        }
    }

    var controller: UIViewController? {
        switch self {
        case .about:
            return InfoMenuAboutTableVC.newInstance()
        //case .develop: :???:NYI: location of develop menu
        //    return UtilityViewController.newInstance()
        case .videos, .book, .cookbook, .diet, .challenge, .donate, .subscribe, .source:
            return nil // not a View Controller
        }
    }
}
