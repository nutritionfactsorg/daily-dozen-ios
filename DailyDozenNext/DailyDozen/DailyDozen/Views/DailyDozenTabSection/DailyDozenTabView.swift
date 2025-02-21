//
//  DailyDozenTabView.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

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
                        Button {
                            print("Info button was tapped")
                        } label: {
                            Image(systemName: "info")
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
        }
    }
}

#Preview {
    DailyDozenTabView()
    //.preferredColorScheme(.dark)
    
}
