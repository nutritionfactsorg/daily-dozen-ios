//
//  ServingsViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import RealmSwift

class ServingsViewController: UIViewController, UITableViewDelegate {

    // MARK: - Outlets
    @IBOutlet private weak var dataProvider: ServingsDataProvider!
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let realm = try? Realm(configuration: RealmConfig.servings.configuration) else {
            fatalError("There should be a realm")
        }

        let doze = realm.objects(Doze.self).first ?? RealmConfig.initialDoze

        dataProvider.viewModel = DozeViewModel(doze: doze)

        tableView.dataSource = dataProvider
        tableView.delegate = self
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
