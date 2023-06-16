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
    private struct Strings {
        static let courier = "Courier"
        static let helveticaBold = "Helvetica-Bold"
        static let helvetica = "Helvetica"
    }
    
    static var courier16: UIFont {
        return UIFont(name: Strings.courier, size: 16) ?? UIFont.systemFont(ofSize: 16)
    }
    
    static var helevetica17: UIFont {
        return UIFont(name: Strings.helvetica, size: 17) ?? UIFont.systemFont(ofSize: 17)
    }
    
    static var heleveticaBold17: UIFont {
        return UIFont(name: Strings.helveticaBold, size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
    }
    
    static var heleveticaBold18: UIFont {
        return UIFont(name: Strings.helveticaBold, size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
    }
    
    static var helveticaBold22: UIFont {
        return UIFont(name: Strings.helveticaBold, size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
    }
}
