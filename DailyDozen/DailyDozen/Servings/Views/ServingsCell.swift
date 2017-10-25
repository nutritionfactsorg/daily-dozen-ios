//
//  ServingsCell.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 23.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import RealmSwift

class ServingsCell: UITableViewCell {

    // MARK: - Nested
    private struct Keys {
        static let cellID = "doseCell"
    }

    // MARK: - Outlets
    @IBOutlet private weak var itemImage: UIImageView!
    @IBOutlet private weak var itemLabel: UILabel!
    @IBOutlet private weak var stateCollection: UICollectionView!

    // MARK: - Properties
    private var states = [Bool]()
    private var id = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        stateCollection.dataSource = self
        stateCollection.delegate = self
    }

    // MARK: - Methods
    /// Sets the item label with the current name and states.
    ///
    /// - Parameter name: The current name.
    /// - Parameter states: The states array.
    func configure(with name: String, id: String, states: [Bool]) {
        itemLabel.text = name
        self.id = id
        self.states.removeAll()
        self.states.append(contentsOf: states)
        stateCollection.reloadData()
    }
}

extension ServingsCell: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return states.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: Keys.cellID, for: indexPath) as? StateCell else {
                    fatalError("There should be a cell")

        }
        cell.configure(with: states[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let state = !states[indexPath.row]
        states[indexPath.row] = state
        guard let cell = collectionView.cellForItem(at: indexPath) as? StateCell else {
            fatalError("There should be a cell")
        }
        cell.configure(with: state)
        if let realm = try? Realm(configuration: RealmConfig.servings.configuration) {
            do {
                try realm.write {
                    realm.create(Item.self, value: ["id": id, "states": states], update: true)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
