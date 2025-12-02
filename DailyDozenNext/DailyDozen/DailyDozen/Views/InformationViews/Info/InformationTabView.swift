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
            //            ForEach((MenuItem.Links)) {
            //                item in
            //                Text(item.wrappedValue)
            //
            //            }
           List {
               Link(destination: getLink(mlink: theMenuLink.videos)) {
                   Text("info_webpage_videos_latest", comment: "Latest Videos")
               }
               Link(destination: getLink(mlink: theMenuLink.book)
               ) {
                   Text("info_book_how_not_to_die", comment: "How Not to Die")
               }
               
               Link(destination: getLink(mlink: theMenuLink.cookbook)
               ) {
                   Text("info_book_how_not_to_die_cookbook", comment: "How Not to Die Cookbook")
               }
            
                Link(destination: getLink(mlink: theMenuLink.diet)
                ) {
                    Text("info_book_how_not_to_diet", comment: "How Not to Diet")
                }
               
               NavigationLink {
                   InfoFaqTableView()
               } label: {
                   Text("faq_title", comment: "FAQ")
               }
               //.accentColor(.black)
              
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
           
               NavigationLink {
                   AboutView()
               } label: {
                   Text("info_app_about", comment: "About")
               }
               
               //This way is hack to get rid of disclosure https://stackoverflow.com/questions/58333499/swiftui-navigationlink-hide-arrow/74198140#74198140
               Text("info_app_about", comment: "About")
                   .background(
                    NavigationLink("", destination: AboutView()
                                  ) .opacity(0)
               )

           }
        
        //.listStyle(.plain)
           .navigationTitle(Text("navtab.info"))
        //.navigationTitle("Information") //GTDz" !!Needs localization
        .navigationBarTitleDisplayMode(.inline)

        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.brandGreen, for: .navigationBar)
        .toolbarColorScheme(.dark) // allows title to be white  //https://www.youtube.com/watch?v=Tf3xqyf6tBQ
        
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
