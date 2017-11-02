//
//  ServingsCell.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 23.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class ServingsCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var itemImage: UIImageView!
    @IBOutlet private weak var itemLabel: UILabel!
    @IBOutlet weak var stateCollection: UICollectionView!
    @IBOutlet weak var infoButton: UIButton!

    // MARK: - Methods
    /// Sets the cell with the current name and tag.
    ///
    /// - Parameter name: The current name.
    /// - Parameter tag: The current tag.
    func configure(with name: String, tag: Int, imageName: String) {
        itemLabel.text = name
        stateCollection.tag = tag
        infoButton.tag = tag
        itemImage.image = UIImage(named: imageName)
    }
}
