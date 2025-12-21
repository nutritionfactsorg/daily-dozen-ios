//
//  AboutView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        Image("logo")
            .resizable()
           // .padding(5)
          // .scaledToFit()
          //.ignoresSafeArea()
    }
}

struct AboutView: View {
    var body: some View {
        NavigationStack {
            VStack {
                
                HeaderView()
                    .scaledToFill()
                    .frame(maxWidth: 500, minHeight: 50, maxHeight: 100) //::NOTEz: check frame sizes
            }
            
            VStack(alignment: .center) {
                ScrollView {
                    Section {
                        VStack {
                            VStack {
                                Image("dr_greger")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 250, height: 250)
                            }
                            
                            Text("info_app_about_welcome")
                                .bold()
                                .font(.title2)  //::GTDz What size
                            // .foregroundStyle(.nfText)
                                .padding(10)
                            Text("info_app_about_overview")
                                .multilineTextAlignment(.leading)
                                .padding(10)
                        }
                        
                    }
                    .foregroundStyle(.nfText)
                    .background(.white)
                    .border(.white) //old: default system white //::TBDz not sure this is even needed
                    .cornerRadius(5)
                    .shadow(color: .nfGray50.opacity(1.0), radius: 5, x: 1, y: 1)
                    //                    .shadow(color: .gray.opacity(1.0), radius: 5, x: 1, y: 1)
                    
                    //::GTD check current app
                    //shadow color sb light gray color
                    
                    .padding(10)
                    
                    Section {
                        DailyDozenAboutCreditView()
                        // .border(.white) //old: default system white //::TBDz not sure this is even needed
                        
                            .shadow(color: .nfGray50.opacity(1.0), radius: 5, x: 1, y: 1)
                        
                    }
                }
                //.background(.gray)
            }
            
            // Spacer()
            //.navigationTitle("info_app_about_heading")
            .whiteInlineGreenTitle("info_app_about_heading")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
             AboutView().preferredColorScheme($0)
        }
    }
}

//#Preview {
//    PreviewProvider {
//        static var previews: some View {
//            ForEach(ColorScheme.allCases, id: \.self) {
//                AboutView().preferredColorScheme($0)
//            }
//        }
//}

//#Preview {
//    
//    AboutView().preferredColorScheme(.light)
//    AboutView().preferredColorScheme(.dark)
//    
////    ForEach(ColorScheme.allCases, id: \.self, content: AboutView().preferredColorScheme)
//        
//}
