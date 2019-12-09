//
//  MenuTableViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

// MARK: - UITableViewController
class MenuTableViewController: UITableViewController {

    // MARK: - Nested
    private struct Strings {
        static let menu = "Menu" // :NYI:ToBeLocalized:
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
        
        if !UserDefaults.standard.bool(forKey: "didCompleteFirstLaunch") {
            UserDefaults.standard.set(true, forKey: "didCompleteFirstLaunch")
            let viewController = FirstLaunchBuilder.instantiateController()
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    /// Presents share services.
    private func presentShareServices() { // Backup
        let fm = FileManager.default
        let urlList = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsUrl = urlList[0]
        let realmMngr = RealmManager(workingDirUrl: documentsUrl)
        let backupFilename = realmMngr.csvExport()
        
        let activityViewController = UIActivityViewController(
            activityItems: [URL.inDocuments(for: backupFilename)],
            applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension MenuTableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuItem = MenuItem(rawValue: indexPath.row) else { return }

        if let link = menuItem.link {
            // Web links
            UIApplication.shared
                .open(LinksService.shared.link(forMenu: link),
                      options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                      completionHandler: nil)
            dismiss(animated: false)
        } else if let controller = menuItem.controller {
            // `AboutViewController`, `ServingsViewController`, `SettingsViewController`
            splitViewController?.showDetailViewController(controller, sender: nil)
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
