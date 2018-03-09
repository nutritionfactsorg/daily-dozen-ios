//
//  Fonts.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 31.01.2018.
//  Copyright © 2018 Nutritionfacts.org. All rights reserved.
//

import UIKit

extension UIFont {

    // MARK: - Nested
    private struct Keys {
        static let helveticaBold = "Helvetica-Bold"
        static let helvetica = "Helvetica"
    }

    static var helevetica: UIFont {
        return UIFont(name: Keys.helvetica, size: 17) ?? UIFont.systemFont(ofSize: 17)
    }

    static var helveticaBold: UIFont {
        return UIFont(name: Keys.helveticaBold, size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
    }
}
