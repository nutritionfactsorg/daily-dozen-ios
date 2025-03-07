//
//  DailyDozenTabView.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
//NYIz: B12/Supplement section not implemented nor link to NF.org
//NYIz: checkbox not implemented
//NYIz: History Buttons
//NYIz: Servings Totals
import SwiftUI

struct DailyDozenTabView: View {
    
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
           
            VStack {
                ForEach(DailyDozenTabView.rowTypeArray, id: \.self) { item in
                    HStack {
                        Image(item.imageName)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                       
                        Text(item.headingDisplay)
                        NavigationLink(destination: DailyDozenDetailView(dataCountTypeItem: item)) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                            //TBDz fontsize?
                        }
                    }
                    .padding(10)
                }
            } //VStack
            .navigationTitle(Text("navtab.doze")) //!!Needs localization comment
            .navigationBarTitleDisplayMode(.inline)
//            
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.brandGreen, for: .navigationBar)
//            .toolbarColorScheme(.dark) // allows title to be white
        } //NavStack
    }
}

#Preview {
    DailyDozenTabView()
    //.preferredColorScheme(.dark)
    
}
