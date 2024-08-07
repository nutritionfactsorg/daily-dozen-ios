//
//  ColorGuide.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct ColorGuide {
    
    enum ColorManagerTheme {
        case primaryDark
        case primaryLight
        case primaryAuto
        case testPreview
    }
    
    static var mainMedium: Color {
        // Color("BrandGreen") 
        return Color(.sRGB, red: 127/255.0, green: 192/255.0, blue: 76/255.0, opacity: 1.0)
    }
    
    static var textWhite: Color {
        return Color.white
    }

    static var textBlack: Color {
        return Color.black
    }
    
    // MARK: - Calendar Colors
    
    static var calendarAllChecked: Color {
        Color(.sRGB, red: 235/255.0, green: 193/255.0, blue: 64/255.0, opacity: 1.0)
    }
    
    static var calendarSomeChecked: Color {
        Color(.sRGB, red: 255/255.0, green: 251/255.0, blue: 0/255.0, opacity: 1.0)
    }
    
    static var calendarNoneChecked: Color {
        Color.white
    }
    
    static var calendarFooter: Color {
        Color(.sRGB, red: 220/255.0, green: 220/255.0, blue: 220/255.0, opacity: 1.0)
    }
    
}
