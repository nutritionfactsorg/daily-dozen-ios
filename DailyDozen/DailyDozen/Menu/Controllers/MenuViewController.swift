//
//  MenuViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

// MARK: - UITableViewController
class MenuViewController: UITableViewController {

    // MARK: - Nested
    private struct Strings {
        static let menu = "Menu"
    }

    private struct Keys {
        static let realm = "main.realm"
    }

    // MARK: - UITableViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""

        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white

        let barItem = UIBarButtonItem(title: Strings.menu, style: .done, target: nil, action: nil)
        barItem.tintColor = UIColor.white
        navigationItem.setLeftBarButton(barItem, animated: false)
    }

    /// Presents share services.
    private func share() {
        let activityViewController = UIActivityViewController(activityItems: [URL.inDocuments(for: Keys.realm)], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension MenuViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuItem = MenuItem(rawValue: indexPath.row) else { return }

        if let link = menuItem.link {
            UIApplication.shared
                .open(LinksService.shared.link(forMenu: link),
                      options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                      completionHandler: nil)
            dismiss(animated: false)
        } else if let controller = menuItem.controller {
            splitViewController?.showDetailViewController(controller, sender: nil)
        } else {
            share()
        }
        tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        super.tableView(tableView, heightForHeaderInSection: section)

        return 0.1
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        super.tableView(tableView, heightForFooterInSection: section)

        return 0.1
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
