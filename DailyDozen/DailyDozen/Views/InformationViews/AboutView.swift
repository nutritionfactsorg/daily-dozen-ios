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
            .aspectRatio(contentMode: .fit)  // Preserves aspect ratio, no distortion
            .frame(maxWidth: .infinity)     // Takes full available width
            .frame(height: 80)
    }
}

struct AboutView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HeaderView()
                    .frame(maxWidth: 500)
                    //.scaledToFill()
                    //.frame(maxWidth: 500, minHeight: 50, maxHeight: 100) // •NOTEz• check frame sizes
                
                VStack(spacing: 20) {
                    ScrollView {
                        VStack(spacing: 20) {
                            VStack(spacing: 16) {
                                // VStack {
                                Image("dr_greger")
                                
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                //.scaledToFill()
                                    .frame(maxWidth: 250, maxHeight: 250)
                                //.frame(maxWidth: min(250, UIScreen.main.bounds.width * 0.6)) // Scales down on smaller screens if needed
                            }
                            //  VStack(alignment: .leading, spacing: 8) {
                            Text("info_app_about_welcome")
                                .bold()
                                .font(.title2)  // •GTDz• What size
                            // .foregroundStyle(.nfText)
                            //   .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity)  // Centers the title horizontally
                            Text("info_app_about_overview")
                                .font(.body)
                                .multilineTextAlignment(.leading)
                            //    .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            //   }
                            //  .frame(maxWidth: .infinity)  // Forces full-width text block
                            //  .padding(.horizontal, 20)   // Consistent readable margin (adjust 16–24 if needed
                        }
                        .padding(.vertical, 10)  // Inner vertical padding
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.nfText)
                        .background(.white)
                        .border(.white) //old: default system white // •TBDz• not sure this is even needed
                        .cornerRadius(5)
                        .shadow(color: .nfGray50.opacity(1.0), radius: 5, x: 1, y: 1)
                        //                    .shadow(color: .gray.opacity(1.0), radius: 5, x: 1, y: 1)
                        
                        // •GTD• check current app
                        //shadow color sb light gray color
                        
                        .padding(.horizontal, 10)
                        .padding(.top, 25)
                        
                        //  Section {
                        DailyDozenAboutCreditView()
                        // .border(.white) //old: default system white // •TBDz• not sure this is even needed
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.nfText)
                            .background(.white)
                            .cornerRadius(5)
                            .shadow(color: .nfGray50.opacity(1.0), radius: 5, x: 1, y: 1)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                        
                        // }
                    }
                    
                    //.background(.gray)
                    .padding(.top, 10)
                }
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
