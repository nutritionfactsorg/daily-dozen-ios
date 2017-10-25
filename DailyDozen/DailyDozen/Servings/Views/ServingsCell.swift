//
//  ServingsCell.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 23.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class ServingsCell: UITableViewCell {

    // MARK: - Nested
    private struct Keys {
        static let cellID = "doseCell"
    }

    // MARK: - Outlets
    @IBOutlet private weak var itemImage: UIImageView!
    @IBOutlet private weak var itemLabel: UILabel!
    @IBOutlet private weak var doseCollection: UICollectionView!

    // MARK: - Properties
    private var doses = [Bool]()

    override func awakeFromNib() {
        super.awakeFromNib()
        doseCollection.dataSource = self
    }

    // MARK: - Methods
    /// Sets the item label with the current name and doses.
    ///
    /// - Parameter name: The current name.
    /// - Parameter doses: The doses array.
    func configure(with name: String, doses: [Bool]) {
        itemLabel.text = name
        self.doses.removeAll()
        self.doses.append(contentsOf: doses)
        doseCollection.reloadData()
    }
}

extension ServingsCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doses.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: Keys.cellID, for: indexPath) as? DoseCell else {
                    fatalError("There should be a cell")

        }
        cell.configure(with: doses[indexPath.row])
        return cell
    }
}
