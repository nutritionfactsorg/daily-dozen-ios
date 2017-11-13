//
//  ImageCell.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 10.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var itemImage: UIImageView!

    // MARK: - Methods
    /// Sets the new item image.
    ///
    /// - Parameter image: The new image.
    func configure(image: UIImage?) {
        itemImage.image = image
    }
}
