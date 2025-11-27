//
//  TwentyOneDetailView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

//TBDz:  Are units supposed to toggle in metric/imperial?
struct TwentyOneDetailView: View {
    let dataCountTypeItem: DataCountType
    @State var tweakDataItemDetail = TweakDetailInfo.Item.example //TBDz need to figure out what goes here besides example
    
    func getDetailItemInfo() {
        tweakDataItemDetail = TweakTextsProvider.shared.getDetails(itemTypeKey: dataCountTypeItem.rawValue)
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
                List {
                    Section {
                        //    VStack(alignment: .leading) {
                        HStack {
                            Text(tweakDataItemDetail.activity.imperial)
                            Spacer()
                        }
                                .padding(5)
                                .background(.white)
                                .cornerRadius(5)
                            //TBDz check color
                                .shadow(color: .nfGray50.opacity(1.0), radius: 5, x: 1, y: 1)
                            //.listRowSeparator(.hidden)
                            //                            }
                            // .listRowSpacing(0.0)
                            // .listStyle(.plain)
                        
                    } //Section
                    header: {
                        VStack(alignment: .leading) {
                            Text("tweak_detail_section_activity")
                               // .bold()
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(10)
                            
                        }
                    }
                    Section {
                        HStack {
                            Text(tweakDataItemDetail.explanation)
                            Spacer()
                        }
//
                            .padding(5)
                            .background(.white)
                            .cornerRadius(5)
                            //TBDz check color
                            .shadow(color: .nfGray50.opacity(1.0), radius: 5, x: 1, y: 1)
                            
                    //    }
                    }//Section
                    header: {
                        Text("tweak_detail_section_description")
                            .bold()
                            .foregroundColor(.black)
                            .font(.title2)
                            .padding(10)
                    }
                    
                } //List
                .listStyle(.plain)
                .navigationTitle(dataCountTypeItem.headingDisplay) //!!GTDz previous version did not have a title
                .navigationBarTitleDisplayMode(.inline)
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Link(destination: LinksService.shared.link(topic: tweakDataItemDetail.topic)) {
//                            Text("videos.link.label", comment: "Latest Videos")
//                        }
//                    }
//                }
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.brandGreen, for: .navigationBar)
                .toolbarColorScheme(.dark)
            }
        }
        .onAppear {
            getDetailItemInfo()
        }
    }
}

#Preview {
    TwentyOneDetailView(dataCountTypeItem: .tweakDailyBlackCumin )
}
