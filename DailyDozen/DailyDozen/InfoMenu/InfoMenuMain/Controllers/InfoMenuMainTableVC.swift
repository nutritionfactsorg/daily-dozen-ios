//
//  InfoMenuMainTableVC.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

// MARK: - UITableViewController
class InfoMenuMainTableVC: UITableViewController {

    // MARK: - UITableViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    /// Presents share services for CSV export backup file.
    private func presentShareServices() { // Backup
        let realmMngr = RealmManager()
        let backupFilename = realmMngr.csvExport(marker: "dailydozen_data")
        
        let activityViewController = UIActivityViewController(
            activityItems: [URL.inDocuments(filename: backupFilename)],
            applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension InfoMenuMainTableVC {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuItem = MenuItem(rawValue: indexPath.row) else { return }

        if let link = menuItem.link {
            // Web links
            UIApplication.shared
                .open(LinksService.shared.link(menu: link),
                      options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                      completionHandler: nil)
            dismiss(animated: false)
        // else if let controller = menuItem.controller {
        } else if let viewController = menuItem.controller {
            // `AboutViewController`
            //let aboutViewController = AboutBuilder.newInstance()
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            presentShareServices() // Backup: iCloud, on device file, ... more
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
