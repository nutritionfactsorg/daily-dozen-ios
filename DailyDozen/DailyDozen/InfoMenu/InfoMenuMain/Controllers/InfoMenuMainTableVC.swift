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

    // MARK: - Menu Labels
    
    @IBOutlet weak var infoAppAboutLabel: UILabel!
    @IBOutlet weak var infoBookHowNotToDieLabel: UILabel!
    @IBOutlet weak var infoBookHowNotToDieCookbookLabel: UILabel!
    @IBOutlet weak var infoBookHowNotToDietLabel: UILabel!
    @IBOutlet weak var infoWebDozeChallengeLabel: UILabel!
    @IBOutlet weak var infoWebDonateLabel: UILabel!
    @IBOutlet weak var infoWebOpenSourceLabel: UILabel!
    @IBOutlet weak var infoWebSubscribeLabel: UILabel!
    @IBOutlet weak var infoWebLatestLatestLabel: UILabel!
    
    // MARK: - UITableViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = ColorManager.style.mainMedium
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        infoAppAboutLabel.text = NSLocalizedString("info_app_about", comment: "About")
        infoBookHowNotToDieLabel.text = NSLocalizedString(
            "info_book_how_not_to_die", comment: "How Not to Die")
        infoBookHowNotToDieCookbookLabel.text = NSLocalizedString(
            "info_book_how_not_to_die_cookbook", comment: "How Not to Die Cookbook")
        infoBookHowNotToDietLabel.text = NSLocalizedString(
            "info_book_how_not_to_diet", comment: "How Not to Diet")
        infoWebDozeChallengeLabel.text = NSLocalizedString(
            "info_webpage_daily_dozen_challenge", comment: "Daily Dozen Challenge")
        infoWebDonateLabel.text = NSLocalizedString(
            "info_webpage_donate", comment: "Donate")
        infoWebOpenSourceLabel.text = NSLocalizedString(
            "info_webpage_open_source", comment: "Open Source")
        infoWebSubscribeLabel.text = NSLocalizedString(
            "info_webpage_subscribe", comment: "Subscribe")
        infoWebLatestLatestLabel.text = NSLocalizedString(
            "info_webpage_videos_latest", comment: "Latest Videos")
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
