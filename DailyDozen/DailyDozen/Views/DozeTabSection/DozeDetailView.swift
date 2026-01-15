//
//  DozeDetailView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

//TBDZ is this the correct gray  check grays in this whole view!!
import SwiftUI

struct DozeDetailView: View {
    
    let dataCountTypeItem: DataCountType
    @State var dataItemDetail = DozeDetailInfo.Item.example
    @State var measurementUnits = "setting_units_0_imperial"
    @State var measureToggle = true
    @State var unitsTypePref: UnitsType = .imperial
    @State var useImperial = true
    
    func setMeasureButton() {
        let shouldShowUnitsToggle = UserDefaults.standard.bool(forKey: SettingsKeys.unitsTypeToggleShowPref)
        measureToggle = shouldShowUnitsToggle
        let unitTypePrefStr =  UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref) ?? "imperial"
        unitsTypePref = UnitsType(rawValue: unitTypePrefStr) ?? .imperial
        
        if unitsTypePref == .imperial {
            //measurementUnits = unitsSegment[0]
            useImperial = true
        }
        if unitsTypePref == .metric {
            //measurementUnits = unitsSegment[1]
            useImperial = false
        }
    }
    
    func getDetailItemInfo() {
        dataItemDetail = DozeTextsProvider.shared.getDetails(itemTypeKey: dataCountTypeItem.rawValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    Image("detail_\(dataCountTypeItem)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    Text(dataCountTypeItem.headingDisplay)
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .shadow(color: .black.opacity(1.0), radius: 2, x: 1, y: 1)
                        .padding()
                } //ZStack
                
                ScrollView {
                    LazyVStack(spacing: 8, pinnedViews: [.sectionHeaders]) {   // ← control spacing here
                        Section {
                            // exact same content you had inside the first Section { … }
                            if useImperial {
                                ForEach(dataItemDetail.servings, id: \.imperial) { item in
                                    HStack {
                                        Text(item.imperial)
                                        Spacer()
                                    }
                                    .padding(10)
                                    .shadowboxed()
                                    .padding(.horizontal, 8)           // optional – your horizontal margins
                                }
                            }
                            if !useImperial {
                                ForEach(dataItemDetail.servings, id: \.metric) { item in
                                    HStack {
                                        Text(item.metric)
                                        Spacer()
                                    }
                                    .padding(10)
                                    .shadowboxed()
                                    .padding(.horizontal, 8)
                                }
                            }
                        } header: {
                            // exact same header you already have
                            VStack(alignment: .leading) {
                                Text("doze_detail_section_sizes")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                  //  .padding(10)
                                
                                if measureToggle {
                                    HStack {
                                        Text("units_label")
                                            .foregroundColor(.gray)  //TBDz  What color here?
                                        Button(action: {
                                            useImperial.toggle()
                                        }, label:
                                                { Text(useImperial ? "setting_units_0_imperial" : "setting_units_1_metric")}
                                        )
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 5)
                                        .background(Color("nfGrayLight"))
                                        .foregroundColor(.black)
                                    }
                                    //.padding(10)
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)   // ← forces full width + left alignment
                            .background(.white)                     //  ← keeps it opaque
                        }
                        
                        Section {
                            ForEach(dataItemDetail.varieties, id: \.text) { item in
                                HStack {
                                    Text(item.text)
                                    Spacer()
                                    if !item.topic.isEmpty {
                                        Link(destination: LinksService.shared.link(topic: item.topic)) {
                                            Text("videos.link.label")
                                        }
                                    }
                                }
                                .padding(10)
                                .shadowboxed()
                                .padding(.horizontal, 8)
                            }
                        } header: {
                            Text("doze_detail_section_types")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.white)                 // ← also opaque here
                        }
                    }
                    .padding(.top, 1)   // tiny offset so first header doesn’t fight with nav bar
                } //Scroll
            }
       
            //.listRowSeparator(.hidden)
           // .listStyle(.plain)
           
            .navigationTitle(dataCountTypeItem.headingDisplay) //!!GTDz previous version did not have a title  keep this for accessibility
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.nfGreenBrand, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Link(destination: LinksService.shared.link(topic: dataItemDetail.topic)) {
                        Text("videos.link.label", comment: "Latest Videos")
                    }
                }
                // 2. Custom white title in the center
                ToolbarItem(placement: .principal) {
                    Text(dataCountTypeItem.headingDisplay)   //  dynamic String
                        .foregroundStyle(.white)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .tracking(-0.4)
                }
            } //toolbar
        } //Navigation
        .onAppear {
            setMeasureButton()
            getDetailItemInfo()
        }
    }
}

#Preview {
    
    DozeDetailView(dataCountTypeItem: .dozeBeans )
    //  .environment(\.locale, .init(identifier: "de"))
}
