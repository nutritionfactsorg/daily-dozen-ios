//
//  SettingsViewController.swift
//  DailyDozen
//
//  Created by Lammert Westerhoff on 21/05/2018.
//  Copyright © 2018 Nutritionfacts.org. All rights reserved.
//

import UIKit

// MARK: - UITableViewController
class SettingsViewController: UITableViewController {

    private struct Keys {
        static let realm = "main.realm"
    }

    // MARK: - UITableViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
    }

    /// Presents share services.
    private func share() {
        let activityViewController = UIActivityViewController(activityItems: [URL.inDocuments(for: Keys.realm)], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let settingsItem = SettingsItem(rawValue: indexPath.row) else { return }

        if let controller = settingsItem.controller {
            navigationController?.pushViewController(controller, animated: true)
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
