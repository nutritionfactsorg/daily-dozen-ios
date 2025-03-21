//
//  DailyDozenView.swift
//  DailyDozen
//
//  Created by mc on 2/17/25.
//

import SwiftUI

struct DailyDozenDetailView: View {
    
    let dataCountTypeItem: DataCountType
    @State var dataItemDetail = DozeDetailInfo.Item.example
    @State var measurementUnits = "setting_units_0_imperial"
    @State var measureToggle = true
    @State var unitsTypePref: UnitsType = .imperial
    @State var useImperial = true
//    var unitsSegment: [String] = [
//        String(localized: "setting_units_0_imperial", comment: "Imperial"),
//        String(localized: "setting_units_1_metric", comment: "Metric")]
//    
    func setMeasureButton() {
        let shouldShowUnitsToggle = UserDefaults.standard.bool(forKey: SettingsKeys.unitsTypeToggleShowPref)
        measureToggle = shouldShowUnitsToggle
        let unitTypePrefStr =  UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref) ?? "imperial"
        unitsTypePref = UnitsType(rawValue: unitTypePrefStr) ?? .imperial
        
        if unitsTypePref == .imperial {
            // measurementUnits = unitsSegment[0]
            useImperial = true
        }
        if unitsTypePref == .metric {
            //   measurementUnits = unitsSegment[1]
            useImperial = false
        }
    }
    
    func getDetailItemInfo() {
        dataItemDetail = DozeTextsProvider.shared.getDetails(itemTypeKey: dataCountTypeItem.rawValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack(alignment: .bottomLeading) {
                    Image("detail_\(dataCountTypeItem)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    Text(dataCountTypeItem.headingDisplay)
                        .foregroundColor(.white)
                        .font(.system(size: 24)).shadow(color: .black.opacity(1.0), radius: 2, x: 1, y: 1)
                        .padding()
                } //ZStack
            }
            List {
                Section {
                    //    VStack(alignment: .leading) {
                    if useImperial {
                        ForEach(dataItemDetail.servings, id: \.imperial) { item in
                           
                            HStack {
                                Text(item.imperial)
                                Spacer() }
                            
                            .padding(5)
                            .background(.white)
                            .cornerRadius(5)
                            //TBDz check color
                            .shadow(color: .nfGray50.opacity(1.0), radius: 5, x: 1, y: 1)
                            //.listRowSeparator(.hidden)
                        }
                        // .listRowSpacing(0.0)
                        // .listStyle(.plain)
                    }
                    if !useImperial {
                        ForEach(dataItemDetail.servings, id: \.metric) { item in
                            HStack {Text(item.metric)
                                Spacer()
                            }
                            .padding(5)
                            .background(.white)
                            .cornerRadius(5)
                            //TBDz check color
                            .shadow(color: .nfGray50.opacity(1.0), radius: 5, x: 1, y: 1)
                         //   .listRowSeparator(.hidden)
                        }
                        //.listRowSpacing(0.0)
                        //  .listStyle(.plain)
                    }
                    
                    //VStack
                    //  } //VStack
                    
                } //Section
                header: {
                    VStack(alignment: .leading) {
                        Text("doze_detail_section_sizes")
                           // .bold()
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(10)
                        
                        if measureToggle {
                            HStack {
                                Text("units_label")
                                    .foregroundColor(.gray)  //TBDZ is this the correct gray
                                Button(action: {
                                    useImperial.toggle()
                                }, label:
                                        { Text(useImperial ? "setting_units_0_imperial" : "setting_units_1_metric")}
                                )// Button
                                .padding(.horizontal, 15)
                                .padding(.vertical, 5)
                                .background(Color("grayLightColor")) //TBDz NF gray
                                .foregroundColor(.black)
                                //.font(.title2)
                            } //HStack
                            .padding(10)
                        } //if
                    }
                }
                Section {
                    
                    ForEach(dataItemDetail.varieties, id: \.text) { item in
        
                        HStack {
                            Text(item.text)
                            Spacer()
                            
                            //TBDz need to do an if statement for if exists
                            if !item.topic.isEmpty {
                                Link(destination: LinksService.shared.link(topic: item.topic)) {
                                    Text("videos.link.label")
                                }
                            } //if topic.isEmpty
                            // Text("")
                            // Text(item.topic)
                            
                        } //HStack
                        .padding(5)
                        .background(.white)
                        .cornerRadius(5)
                        //TBDz check color
                        .shadow(color: .nfGray50.opacity(1.0), radius: 5, x: 1, y: 1)
                        //  .shadow(color: Color.black.opacity(0.3), radius: 5) // Add drop shadow
                        // .listRowSeparator(.hidden)
                        
                        //  .listRowSpacing(0)
                    }
                }//Section
                header: {
                    Text("doze_detail_section_types")
                        .bold()
                        .foregroundColor(.black)
                        .font(.title2)
                        .padding(10)
                }
                
            } //List
            .listStyle(.plain)
            .navigationTitle(dataCountTypeItem.headingDisplay) //!!GTDz previous version did not have a title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Link(destination: LinksService.shared.link(topic: dataItemDetail.topic)) {
                        Text("videos.link.label", comment: "Latest Videos")
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.brandGreen, for: .navigationBar)
            .toolbarColorScheme(.dark)
        } //Navigation
        .onAppear {
            setMeasureButton()
            getDetailItemInfo()
        }
        
    }
}

#Preview {
   
    DailyDozenDetailView(dataCountTypeItem: .dozeBeans )
      //  .environment(\.locale, .init(identifier: "de"))
}
