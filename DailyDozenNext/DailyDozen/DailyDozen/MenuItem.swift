//
//  MenuItem.swift
//  NFTest
//
//
import SwiftUI

enum MenuItem: Int, CaseIterable, Identifiable {
    var id: Self {self}
    // MARK: - Nested
    
    /// Links: provides url path component "https://nutritionfacts.org/COMPONENT/"
    /// :NYI:ToBeLocalized: web link components
    /// EN: "https://nutritionfacts.org/donate/"
    /// ES: "https://nutritionfacts.org/es/dona-a-nutritionfacts-org/"
    struct URLLinks {
        static let videos = String(localized:
            "urlSegmentInfoMenu.videos",
            comment: "main info menu: videos")
        static let book = String(localized:
            "urlSegmentInfoMenu.book",
            comment: "main info menu: book")
        static let cookbook = String(localized:
            "urlSegmentInfoMenu.cookbook",
            comment: "main info menu: cookbook")
        static let diet = String(localized:
            "urlSegmentInfoMenu.diet",
            comment: "main info menu: how-not-to-diet")
        static let challenge = String(localized:
            "urlSegmentInfoMenu.challenge",
            comment: "main info menu: daily-dozen-challenge")
        static let donate = String(localized:
            "urlSegmentInfoMenu.donate",
            comment: "main info menu: donate")
        static let subscribe = String(localized:
            "urlSegmentInfoMenu.subscribe",
            comment: "main info menu: subscribe")
        static let source = String(localized:
            "urlSegmentInfoMenu.source",
            comment: "main info menu: open-source")
    }
///MJ insert temp
    
    /// Defines item order for `InfoMenuMainTableVC`
    case videos, book, cookbook, diet, faq, challenge, donate, subscribe, source, about

//    var link: String? { 
//        switch self {
//        case .videos:
//            return URLLinks.videos
//        case .book:
//            return URLLinks.book
//        case .cookbook:
//            return URLLinks.cookbook
//        case .diet:
//            return URLLinks.diet
//        case .faq:
//            return nil // not a URL link
//        case .challenge:
//            return URLLinks.challenge
//        case .donate:
//            return URLLinks.donate
//        case .subscribe:
//            return URLLinks.subscribe
//        case .source:
//            return URLLinks.source
//        case .about:
//            return nil // not a URL link
//        }
 //   }

//    var controller: UIViewController? {
//        switch self {
//        case .about:
//            return InfoMenuAboutTableVC.newInstance()
//        case .faq:
//            return InfoFaqTableViewController()
//        // case .develop: :???:NYI: location of develop menu
//        //    return UtilityViewController.newInstance()
//        case .videos, .book, .cookbook, .diet, .challenge, .donate, .subscribe, .source:
//            return nil // not a View Controller
//        }
//    }
}


