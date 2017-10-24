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

    // MARK: - Methods
    /// Sets the item label with the current name.
    ///
    /// - Parameter name: The current name.
    func configure(with name: String) {
        itemLabel.text = name
    }
}
