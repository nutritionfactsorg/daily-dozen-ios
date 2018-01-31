//
//  LinkService.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 13.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation

class LinksService {

    // MARK: - Nested
    private struct Keys {
        static let baseURL = "base_url"
    }

    private struct URLKeys {
        static let topics = "topics"
        static let book = "book"
        static let team = "team"
    }

    private struct Authors {
        static let christi = "https://github.com/christirichards"
        static let const = "https://github.com/justaninja"
    }

    // MARK: - Properties
    private let baseURL: URL

    var siteMain: URL {
        return baseURL
    }

    var siteBook: URL {
        return baseURL
            .appendingPathComponent(URLKeys.book)
    }

    var team: URL {
        return baseURL
            .appendingPathComponent(URLKeys.team)
    }

    var authorChristi: URL? {
        return URL(string: Authors.christi)
    }

    var authorConst: URL? {
        return URL(string: Authors.const)
    }

    /// Returns the shared LinksService object.
    static let shared: LinksService = {
        guard let path = Bundle.main.path(
            forResource: "LinkSettings",
            ofType: "plist") else {
                fatalError("There should be a settings file")
        }

        guard let dictionary = NSDictionary(contentsOfFile: path) else {
            fatalError("There should be a settings dictionary")
        }

        guard let urlString = dictionary[Keys.baseURL] as? String,
            let url = URL(string: urlString) else {
                fatalError("There should be a base URL")
        }

        return LinksService(url: url)
    }()

    // MARK: - Inits
    private init(url: URL) {
        baseURL = url
    }

    /// Returns a url for the current topic.
    ///
    /// - Parameter topic: The current topic.
    /// - Returns: A url.
    func link(forTopic topic: String) -> URL {
        return baseURL
            .appendingPathComponent(URLKeys.topics)
            .appendingPathComponent(topic)
    }

    /// Returns a url for the current menu item.
    ///
    /// - Parameter menu: The current menu item.
    /// - Returns: A url.
    func link(forMenu menu: String) -> URL {
        return baseURL
            .appendingPathComponent(menu)
    }
}
