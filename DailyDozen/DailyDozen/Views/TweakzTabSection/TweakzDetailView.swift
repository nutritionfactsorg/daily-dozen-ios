//
//  TweakzDetailView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

// •TBDz•  Are units supposed to toggle in metric/imperial?
struct TweakzDetailView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let dataCountTypeItem: DataCountType
    @State var tweakDataItemDetail = TweakDetailInfo.Item.example //TBDz need to figure out what goes here besides example
    
    func getDetailItemInfo() {
        tweakDataItemDetail = TweakTextsProvider.shared.getDetails(itemTypeKey: dataCountTypeItem.rawValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Hero Image + Title Overlay
                ZStack(alignment: .bottomLeading) {
                    Image("detail_\(dataCountTypeItem)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    Text(dataCountTypeItem.headingDisplay)
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .shadow(color: .black.opacity(1.0), radius: 2, x: 1, y: 1)
                        .padding()
                }
                
                // MARK: - Scrollable Content with Pinned Section Headers
                ScrollView {
                    LazyVStack(spacing: 8, pinnedViews: dynamicTypeSize.isAccessibilitySize ? [] : [.sectionHeaders]) {
                        
                        // MARK: Activity Section
                        Section {
                            HStack {
                                Text(tweakDataItemDetail.activity.imperial)
                                Spacer()
                            }
                            .padding(10)
                            .shadowboxed()
                            .padding(.horizontal, 8)
                        } header: {
                            Text("tweak_detail_section_activity")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.white)
                        }
                        
                        // MARK: Description Section
                        Section {
                            HStack {
                                Text(tweakDataItemDetail.explanation)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(10)
                            .shadowboxed()
                            .padding(.horizontal, 8)
                        } header: {
                            Text("tweak_detail_section_description")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.white)
                        }
                        
                    }
                    .padding(.top, 1)
                }
            }
            // MARK: - Navigation Bar
            .navigationTitle(dataCountTypeItem.headingDisplay)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.nfGreenBrand, for: .navigationBar)
            .toolbarColorScheme(.dark)
            .toolbar {
                // Uncomment when you want the video link back
                // ToolbarItem(placement: .navigationBarTrailing) {
                //     Link(destination: LinksService.shared.link(topic: tweakDataItemDetail.topic)) {
                //         Text("videos.link.label")
                //     }
                // }
                
                ToolbarItem(placement: .principal) {
                    Text(dataCountTypeItem.headingDisplay)
                        .foregroundStyle(.white)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .tracking(-0.4)
                }
            }
        }
        .onAppear {
            getDetailItemInfo()
        }
    }
}

#Preview {
    TweakzDetailView(dataCountTypeItem: .tweakDailyBlackCumin )
}
