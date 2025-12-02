//
//  ContentView.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct ContentView: View {
//    init() {
//           UITabBar.appearance().isTranslucent = false
//          // UITabBar.appearance().backgroundColor = .white  //Could be set to something else
//      }
    
    var body: some View {
        TabView {
            DozeTabView()
            //DailyDozenTabView()
                .tabItem {
                    Label {
                        
                        Text("navtab.doze", comment: "Daily Dozen (proper noun) navigation tab")
                    } icon: {
                        Image(systemName: "square.fill")
                    }
                }
            
           // SecondTabViewR()
            TwentyOneTweaksTabView()
              
                .tabItem {
                    Label {
                        Text("navtab.tweaks", comment: "21 Tweaks (proper noun) navigation tab")
                    } icon: {
                        Image(systemName: "circle.fill")
                    }
                }
            //!!NYI:  accessibilityIdentifier
            InformationTabView()
                .tabItem {
                    Label {Text("navtab.info", comment: "More Information navigation tab")
                    }
                    icon: {Image(systemName: "info.square.fill")
                    }
                }
            PreferencesTabView()
                .tabItem {
                    Label {Text("navtab.preferences", comment: "Preferences (aka Settings, Configuration) navigation tab.")
                    } icon: {Image(systemName: "gearshape.fill")
                    }
                }
        }
        .tint(Color(.tabAccent))
        .toolbarBackground(

               // 1
               Color.white,
               // 2
               for: .tabBar)
    }
}

#Preview {
   ContentView().preferredColorScheme(.dark)
   
   //  .environment(\.locale, .init(identifier: "de"))
}
