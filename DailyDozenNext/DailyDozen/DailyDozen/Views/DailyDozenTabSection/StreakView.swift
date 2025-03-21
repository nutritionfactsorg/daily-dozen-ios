//
//  StreakView.swift
//  DailyDozen
//
//  Created by mc on 3/11/25.
//

import SwiftUI

struct StreakView: View {
    var streak = 0
    private let oneDay = 1
    private let oneWeek = 7
    private let twoWeeks = 14
    // var streakViewHidden = false
    
    private var backgroundColor: Color {
        if streak < oneWeek {
            return Color.streakBronze
        } else if streak < twoWeeks {
            return Color.streakSilver
        } else {
            return Color.streakGold
        }
    }
    
    private var textColor: Color {
        if streak < oneWeek {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    var body: some View {
        //TBDz don't know if smaller screens are relevant
        if streak > oneDay { // "1 day" streaks are not shown
            let streakFormat = String(localized: "streakDaysFormat")
            //            if itemType == .dozeBeverages && self.frame.width < 374.0 {
            //                // Daily Dozen beverages has 5 checkboxs overlays the streak indicator on small screens.
            //                // which requires the `%d days` label to be shortened to just then number.
            //                streakFormat = "%d" // no units
            //                if streak > 999 {
            //                    streakFormat = "🏆" // trophy prize
            //                }
            //
            //                // Note: adjust contraint instead, if needed.
            //                //var f = itemStateCollection.frame
            //                //f.size.width = 33.0 // 165.0 / 5.0 = 33
            //                //itemStateCollection.frame = f
            //            }
            
            //let nf = NumberFormatter()
            let daysStr = String(streak)
            
            let str = streakFormat.replacing("%d", with: daysStr)
            Text(str)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(backgroundColor) // Using computed property for color
                )
                .foregroundStyle(textColor)
            
        } else {
            // streakViewHidden = true
        }
        
    }
}

#Preview {
    StreakView()
}
