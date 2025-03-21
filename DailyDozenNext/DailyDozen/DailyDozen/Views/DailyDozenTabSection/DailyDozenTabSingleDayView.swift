//
//  DailyDozenTabView.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
//NYIz: B12/Supplement section not implemented nor link to NF.org
//NYIz: checkbox activity not implemented
//NYIz: History Buttons
//NYIz: Servings Totals
//NYIz: Vitamin B12 separate section
//NYIz: Streak is currently hardcoded
//NYIz: What does the star do?
import SwiftUI

struct DailyDozenTabSingleDayView: View {
    var streakCount = 3000 // NYIz just a placeholder for now
    static let rowTypeArray: [DataCountType] = [
        .dozeBeans,
        .dozeBerries,
        .dozeFruitsOther,
        .dozeVegetablesCruciferous,
        .dozeGreens,
        .dozeVegetablesOther,
        .dozeFlaxseeds,
        .dozeNuts,
        .dozeSpices,
        .dozeWholeGrains,
        .dozeBeverages,
        .dozeExercise,
        .otherVitaminB12
    ]
  
    var body: some View {
        NavigationStack {
            HStack {
                Text("doze_entry_header")
                Spacer()
                Text("4/24") //TBDz, NYI
                Image("ic_stat")
            }
            .padding(10)
            
           ScrollView {
                VStack {
                    ForEach(DailyDozenTabSingleDayView.rowTypeArray, id: \.self) { item in
                        HStack {
                            Image(item.imageName)
                                .resizable()
                                .scaledToFit()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .padding(5)
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(item.headingDisplay)
                                        .padding(5)  // system images have built-in 5 padding.  TBDz see if there's another way to align
                                    Spacer()
                                    NavigationLink(destination: DailyDozenDetailView(dataCountTypeItem: item)) {
                                        Image(systemName: "info.circle")
                                        //   .font(.system(size: 12))
                                        //TBDz fontsize?
                                            .foregroundColor(.nfDarkGray)
                                    }
                                }
                          
                                HStack {
                                    Image("ic_calendar")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                    StreakView(streak: streakCount)
                                    Spacer()
                                    HStack(spacing: 5) {
                                        ForEach(0..<item.goalServings, id: \.self) { index in
                                             //TBDz I imagine the index will be used later
                                                CheckboxView(isChecked: true)
                                                //TBDz need to work on toggle and actual checks
                                            
                                        } //ForEach
                                    } //HStack
                                   
                                }
                            }

                        } //HStack
                       // .padding(10)
                    }
                    .padding(10)
                    .shadowboxed()

                } //VStack
//                .navigationTitle(Text("navtab.doze")) //!!Needs localization comment
//                .navigationBarTitleDisplayMode(.inline)
//                //
//                .toolbarBackground(.visible, for: .navigationBar)
//                .toolbarBackground(.brandGreen, for: .navigationBar)
                //            .toolbarColorScheme(.dark) // allows title to be white
           } //Scroll
        } //NavStack
    }
}

#Preview {
    DailyDozenTabSingleDayView()
    //.preferredColorScheme(.dark)
    
}
