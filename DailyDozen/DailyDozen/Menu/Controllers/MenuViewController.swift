//
//  MenuViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    // MARK: - Nested
    private struct Links {
        static let videos = "videos"
        static let book = "book"
        static let donate = "donate"
        static let subscribe = "subscribe"
        static let source = "open-source"
    }

    private enum MenuItem: Int {

        case servings, videos, book, donate, subscribe, source, settings, backup, about

        var link: String? {
            switch self {
            case .servings, .settings, .backup, .about:
                return nil
            case .videos:
                return Links.videos
            case .book:
                return Links.book
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
            case .servings:
                return PagerBuilder.instantiateController()
            case .about:
                return AboutBuilder.instantiateController()
            case .settings:
                return ReminderBuilder.instantiateController()
            case .videos, .book, .donate, .subscribe, .source, .backup:
                return nil
            }
        }
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let menuItem = MenuItem(rawValue: indexPath.row) else { return }

        if let link = menuItem.link {
            UIApplication.shared
                .open(LinksService.shared.link(forMenu: link),
                      options: [:],
                      completionHandler: nil)
            dismiss(animated: false)
        } else if let controller = menuItem.controller {
            splitViewController?.showDetailViewController(controller, sender: nil)
        } else {
            share()
        }
    }

    private func share() {
        let activityViewController = UIActivityViewController(activityItems: [URL.inDocuments(for: "main.realm")], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }
}
