//
//  Colors.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 29.01.2018.
//  Copyright © 2018 Nutritionfacts.org. All rights reserved.
//

import UIKit

/// `*Color` suffix used for NutritionFacts app specific colors.
extension UIColor {
    
    /// rgb(69,66,82) `#3C4252`
    static var blueDarkColor: UIColor {
        return UIColor(red: 60/255, green: 66/255, blue: 82/255, alpha: 1)
    }
    
    /// rgb(213,213,213) `#D5D5D5` Grayscale 84%
    static var grayLightColor: UIColor {
        return UIColor(red: 213/255, green: 213/255, blue: 213/255, alpha: 1)
    }
    
    /// rgb(127,192,76) `#7FC04C`
    static var greenColor: UIColor {
        return UIColor(red: 127/255, green: 192/255, blue: 76/255, alpha: 1)
    }
    
    /// rgb(174,215,142) `#AED78E`
    static var greenLightColor: UIColor {
        return UIColor(red: 174/255, green: 215/255, blue: 142/255, alpha: 1)
    }
    
    /// rgb(255, 82, 82) `#FF5252`
    static var redCheckmarkColor: UIColor {
        return UIColor(red: 255/255, green: 82/255, blue: 82/255, alpha: 1)
    }
    
    /// rgb(198,108,108) `#C66C6C`
    static var redDarkColor: UIColor {
        return UIColor(red: 198/255, green: 108/255, blue: 108/255, alpha: 1)
    }
    
    /// rgb(235,193,64) `#EBC140`
    static var yellowColor: UIColor {
        return UIColor(red: 235/255, green: 193/255, blue: 64/255, alpha: 1)
    }
    
}
