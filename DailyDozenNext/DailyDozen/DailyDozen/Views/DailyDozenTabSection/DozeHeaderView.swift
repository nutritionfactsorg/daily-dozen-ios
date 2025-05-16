//
//  DozeHeaderView.swift
//  DailyDozen
//
//  Created by mc on 3/27/25.
//

import SwiftUI

struct DozeHeaderViewWAS: View {
   
        @Binding var isShowingSheet: Bool
        
        var body: some View {
            VStack {
                Button(action: {
                    isShowingSheet.toggle()
                }, label: {
                    Text("Select Date")
                        .frame(width: 300, height: 30, alignment: .center)
                })
                .buttonStyle(.borderedProminent)
                .tint(.brandGreen)
                .padding(5)
                
                HStack {
                    Text("doze_entry_header")
                    Spacer()
                    Text("4/24")
                    // TBDz, NYI
                   
                    Image("ic_stat")
                }
                .padding(10)
            }
        }
}

struct DozeHeaderView: View {
    @Binding var isShowingSheet: Bool
    let currentDate: Date // Pass the current date from ContentView
   // let dozeDailyStateCount: Int
    
    private var buttonTitle: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
//        return calendar.isDate(currentDate, inSameDayAs: today) ? String(localized:"dateButtonTitle.today") : currentDate.formatted(date: .abbreviated, time: .omitted)  //TBDz format
//
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
        .tint(.brandGreen)
        .padding(5)
//        
//           HStack {
//            Text("doze_entry_header")
//            Spacer()
//           // Text("4/24") // TBDz, NYI
//            Text("\(dozeDailyStateCount)/24")
//            //Text("\(dozeDailyStateCount)/\(DozeEntryViewModel.rowTypeArray.reduce(0) { $0 + $1.goalServings })")
//            Image("ic_stat")
//        }
//        .padding(10)
    }
}

//#Preview {
//    DozeHeaderView(isShowingSheet: true)
//}
