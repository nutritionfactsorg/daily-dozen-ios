//
//  Fonts.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 31.01.2018.
//  Copyright © 2018 Nutritionfacts.org. All rights reserved.
//

import UIKit

extension UIFont {
    
    static var fontMonoSystem16: UIFont {
        return UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
    }
    
    static var fontSystem17: UIFont {
        return UIFont.systemFont(ofSize: 17)
    }
    
    static var fontSystemBold17: UIFont {
        return UIFont.boldSystemFont(ofSize: 17)
    }
    
    static var fontSystemBold18: UIFont {
        return UIFont.boldSystemFont(ofSize: 18)
    }
    
    static var fontSystemBold22: UIFont {
        return UIFont.boldSystemFont(ofSize: 22)
    }
    
    static var fontSystemMedium17: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: .medium)
    }
    
    /// :SWIFTUI:NYI: consider `preferredFont(forTextStyle:)`
    /// Consider using `preferredFont(forTextStyle:UITraitCollection:)` 
    /// instead of `systemFont`, `boldSystemFont`, `italicSystemFont`
    /// 
    /// See also:
    /// - https://developer.apple.com/documentation/uikit/uifont/textstyle
    /// - https://developer.apple.com/documentation/uikit/uitraitcollection/
    static func dailydozenBodyFont(traits: UITraitCollection? = nil) -> UIFont {
        return UIFont.preferredFont(
            forTextStyle: TextStyle.body, 
            compatibleWith: traits
        )
    }
    
}
