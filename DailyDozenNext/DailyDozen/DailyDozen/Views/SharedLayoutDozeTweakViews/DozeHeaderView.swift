//
//  DozeHeaderView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct DozeHeaderView: View {
    @Binding var isShowingSheet: Bool
    let currentDate: Date // Pass the current date from ContentView
   // let dozeDailyStateCount: Int
    
    private var buttonTitle: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if calendar.isDate(currentDate, inSameDayAs: today) {
                    return String(localized: "dateButtonTitle.today")
                } else {
                    // Use DateFormatter for explicit control (iOS 16+ compatible)
                    let formatter = DateFormatter()
                    formatter.dateStyle = .long
                    formatter.timeStyle = .none
                    return formatter.string(from: currentDate)
                }
        
    }
    
    var body: some View {
        Button(action: { isShowingSheet.toggle() }, label: {
            Text(buttonTitle)
                .frame(width: 300, height: 30, alignment: .center)
        })
        .buttonStyle(.borderedProminent)
        .tint(.nfGreenBrand)
        .padding(5)
//        

    }
}

#Preview {
    @Previewable @State var isShowing = true
    DozeHeaderView(isShowingSheet: $isShowing, currentDate: Date())
}

// :TBDz:  Check this layout later:
//Button(action: {
//print("DozeHeaderView button tapped, isShowingSheet: \(isShowingSheet) -> \(!isShowingSheet)")
//isShowingSheet.toggle()
//}, label: {
//Text(buttonTitle)
//    .frame(maxWidth: .infinity)
//    .padding()
//    .background(Color.nfGreenBrand.opacity(0.2))
//    .foregroundColor(.nfGreenBrand)
//    .cornerRadius(8)
//    .overlay(
//        RoundedRectangle(cornerRadius: 8)
//            .stroke(Color.nfGreenBrand, lineWidth: 1)
//    )
//})
//.buttonStyle(.plain) // Avoid default styling issues
//.padding(.horizontal, 10)
//.padding(.vertical, 5)
//.background(Color.gray.opacity(0.1)) // Debug: Highlight view bounds
