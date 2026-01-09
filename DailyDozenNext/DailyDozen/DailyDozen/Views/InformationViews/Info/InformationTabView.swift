//
//  InformationTabView.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct InformationTabView: View {
    @State private var path = NavigationPath()
    
    @State private var theMenuLink = MenuItem.URLLinks.self //needs definition
    @State private var linkService = LinksService.shared
    func getLink(mlink: String) -> URL {
        // var urlSegment = String(localized: "urlSegmentInfoMenu.book")
        // var baseU = linkService.siteMain
        // let appendU = linkService.link(menu:urlSegment)
        
        let appendU = linkService.link(menu: mlink)
        
        // print(appendU)
        return appendU
    }
    var body: some View {
        //  NavigationStack(path: $selectedPath) {
        NavigationStack {
            
            List {
                Link(destination: getLink(mlink: theMenuLink.videos)) {
                    Text("info_webpage_videos_latest", comment: "Latest Videos")
                }
                Link(destination: getLink(mlink: theMenuLink.book)
                ) {
                    Text("info_book_how_not_to_die", comment: "How Not to Die")
                }
//                Button {
//                    let url = getLink(mlink: theMenuLink.book)
//                    UIApplication.shared.open(url)
//                } label: {
//                    Text("info_book_how_not_to_die", comment: "How Not to Die")
//                        .foregroundColor(.blue)           // makes it look exactly like a Link
//                        .underline()                      // optional – adds the underline if you had it
//                }
//                .buttonStyle(.plain)                       // removes any button shading/background
                
                Link(destination: getLink(mlink: theMenuLink.cookbook)
                ) {
                    Text("info_book_how_not_to_die_cookbook", comment: "How Not to Die Cookbook")
                        .onOpenURL { url in
                                    print("onOpenURL fired with \(url)")   // ← this will print
                                }
                }
                
                Link(destination: getLink(mlink: theMenuLink.diet)
                ) {
                    Text("info_book_how_not_to_diet", comment: "How Not to Diet")
                }
                
//                NavigationLink {
//                    InfoFaqTableView()
//                } label: {
//                    Text("faq_title", comment: "FAQ")
//                }
                //.accentColor(.black)
                //Used as hack to make consistent with ios 26 and remove disclsoure indicator
                Text("faq_title", comment: "FAQ")
                    .background(
                        NavigationLink("", destination: InfoFaqTableView()
                                      ) .opacity(0)
                    )
                
                Link(destination: getLink(mlink: theMenuLink.challenge)) {
                    Text( "info_webpage_daily_dozen_challenge", comment: "Daily Dozen Challenge")
                }
                
                Link(destination: getLink(mlink: theMenuLink.donate)) {
                    Text( "info_webpage_donate", comment: "Donate")
                }
                
                Link(destination: getLink(mlink: theMenuLink.subscribe)) {
                    Text( "info_webpage_subscribe", comment: "Subscribe")
                }
                
                Link(destination: getLink(mlink: theMenuLink.source)) {
                    Text( "info_webpage_open_source", comment: "Open Source")
                }
                
//                NavigationLink {
//                    AboutView()
//                } label: {
//                    Text("info_app_about", comment: "About")
//                }
                
//                NavigationLink {
//                    TestLinkView()
//                } label: {
//                    Text("TEST TEST", comment: "TEST")
//                }
                Text("info_app_about", comment: "About")
                    .background(
                        NavigationLink("", destination: AboutView()
                                      ) .opacity(0)
                    )
            }
            .whiteInlineGreenTitle("navtab.info")
            .navigationLinkIndicatorVisibility(.hidden)
            //               //This way is hack to get rid of disclosure https://stackoverflow.com/questions/58333499/swiftui-navigationlink-hide-arrow/74198140#74198140
            //               Text("info_app_about", comment: "About")
            //                   .background(
            //                    NavigationLink("", destination: AboutView()
            //                                  ) .opacity(0)
            //               )
            
            //.listStyle(.plain)
         
//            .navigationTitle(Text("navtab.info"))  // Still needed for accessibility/large title fallback
//            .navigationBarTitleDisplayMode(.inline)
//            
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbarBackground(.nfGreenBrand, for: .navigationBar)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("navtab.info", comment: "Info tab")  // Or just Text("navtab.info")
//                        .foregroundStyle(.white)
//                        .font(.system(size: 17, weight: .semibold, design: .default))  // Matches system inline title exactly
//                }
//            }
            //.toolbarColorScheme(.dark) // allows title to be white  //https://www.youtube.com/watch?v=Tf3xqyf6tBQ
            
            // !!GTDz: hack doesn't always seem to work.
        }
        
    }
}

struct InformationTabView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            InformationTabView().preferredColorScheme($0)
        }
    }
}
