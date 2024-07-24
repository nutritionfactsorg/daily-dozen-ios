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
    
    // MARK: - Calendar Colors
    
    static var calendarAllChecked: Color {
        Color(.sRGB, red: 235/255, green: 193/255, blue: 64/255, opacity: 1.0)
    }
    
    static var calendarSomeChecked: Color {
        Color(.sRGB, red: 255/255, green: 251/255, blue: 0/255, opacity: 1.0)
    }
    
    static var calendarNoneChecked: Color {
        Color.white
    }
    
}
