//
//  MenuViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard indexPath.row == 0 else { return }
        let controller = PagerBuilder.instantiateController()
        splitViewController?.showDetailViewController(controller, sender: nil)
    }
}
