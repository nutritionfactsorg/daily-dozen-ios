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
    var unitsSegment: [String] = [
        String(localized: "setting_units_0_imperial", comment: "Imperial"),
        String(localized: "setting_units_1_metric", comment: "Metric")]
    //    var dataItemDetail: () -> DozeDetailInfo.Item {
    //        return DozeTextsProvider.shared.getDetails(itemTypeKey: dataCountTypeItem.rawValue)
    //   }
    // var dataItemDetail: DozeDetailInfo
    // var dataViewModel: DozeDetailViewModel
    //@State var dataDetailItem: DozeDetailInfo.Item
    
    //    init(dataDetailItem: DozeDetailInfo.Item, dataCountTypeItem: DataCountType) {
    //        self.dataDetailItem = DozeTextsProvider.shared.getDetails(itemTypeKey: dataCountTypeItem.rawValue)
    //        self.dataCountTypeItem = dataCountTypeItem
    //    }
    //
    //    public init(dataDetailItem: DozeDetailInfo.Item, dataCountTypeItem: DataCountType) {
    //        self.dataDetailItem = dataDetailItem
    //        self.dataCountTypeItem = dataCountTypeItem
    //    }
    
    func goToVideo() {
        print("video button pushed")
        //let topicUrl = .topicURL
    }
    
    func unitButtonToggle() {
        print("Toggle")
    }
    
   func setMeasureButton() {
        let shouldShowUnitsToggle = UserDefaults.standard.bool(forKey: SettingsKeys.unitsTypeToggleShowPref)
        measureToggle = shouldShowUnitsToggle
        let unitTypePrefStr =  UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref) ?? "imperial"
       unitsTypePref = UnitsType(rawValue: unitTypePrefStr) ?? .imperial
       
        if unitsTypePref == .imperial {
            measurementUnits = unitsSegment[0]
        }
        if unitsTypePref == .metric {
            measurementUnits = unitsSegment[1]
        }
    }
    
    func getDetailItemInfo() {
        dataItemDetail = DozeTextsProvider.shared.getDetails(itemTypeKey: dataCountTypeItem.rawValue)
        print(dataItemDetail)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Section {
                  //  VStack {
                        
                        ZStack(alignment: .bottomLeading) {
                        Image("detail_\(dataCountTypeItem)")
                            .resizable()
                           // .frame(width: 320, height: 200) //TBDz determine frame size
                            .aspectRatio(contentMode: .fill)
                          
                        Text(dataCountTypeItem.headingDisplay)
                                .foregroundColor(.white)
                                .font(.system(size: 24)).shadow(color: .black.opacity(1.0), radius: 2, x: 1, y: 1)
                                .padding()
                        } //ZStack
                       
                  //  }//VStack
                } //Section
                Section {

                        VStack(alignment: .leading) {
                            Text("doze_detail_section_sizes")
                                .bold()
                                .font(.title3)
                            
                            if measureToggle {
                                HStack {
                                    Text("units_label")
                                        .foregroundColor(.gray)  //TBDZ is this the correct gray
                                    Button(measurementUnits, action: unitButtonToggle)
                                        .padding(5)
                                        .background(Color("grayLightColor")) //TBDz NF gray
                                        .foregroundColor(.black)
                                    //.font(.title2)
                                } //HStack
                            } //if
                            
                            if unitsTypePref == .imperial {
                                List(dataItemDetail.servings, id: \.imperial) { item in
                                    Text(item.imperial)
                                }
                            }
                            
                            if unitsTypePref == .metric {
                                List(dataItemDetail.servings, id: \.metric) { item in
                                    Text(item.metric)
                                }
                            }
                        } //VStack
                    } //Section
                Section {
                    VStack {
                        Text("doze_detail_section_types")
                            //.multilineTextAlignment(.leading)
                            .bold()
                            .font(.title3)
                        
                        // Text(dataItemDetail.heading)
                        //  Text(dataItemDetail.topic)
                        //Text(dataItemDetail.varieties[0].text)
                        List(dataItemDetail.varieties, id: \.text) { item in
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
                            .listRowSeparator(.hidden)
                            
                            //  .listRowSpacing(0)
                        } //List
                        .listRowSpacing(0.0)
                        .listStyle(.plain)
                        // .listRowSeparator(.hidden)
                        
                        // Text(dataItemDetail.servings)
                    }//VStack
                }//Section
                
            } //VStack
            
            .navigationTitle(dataCountTypeItem.headingDisplay) //!!GTDz previous version did not have a title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Link(destination: LinksService.shared.link(topic: dataItemDetail.topic)) {
                                            Text("videos.link.label", comment: "Latest Videos")
                                        }
                    //                    Button("Videos", action: goToVideo) //GTDz:  needs localization
                    
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.brandGreen, for: .navigationBar)
            .toolbarColorScheme(.dark)
        } //Navigation
        .onAppear {
            setMeasureButton()
            getDetailItemInfo()
            
            //            print( DozeTextsProvider.shared.getDetails(itemTypeKey: dataCountTypeItem.rawValue))
            //            dataDetailItem = DozeTextsProvider.shared.getDetails(itemTypeKey: dataCountTypeItem.rawValue)
            //  print(dataDetailItem.heading)
            // print(dataDetailItem.topic)
        }
        
    }
}

#Preview {
   
    DailyDozenDetailView(dataCountTypeItem: .dozeBeans )
      //  .environment(\.locale, .init(identifier: "de"))
}
