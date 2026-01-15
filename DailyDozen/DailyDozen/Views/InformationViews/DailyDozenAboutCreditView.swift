//
//  DailyDozenAboutThanksView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct DailyDozenAboutCreditView: View {
    var body: some View {
        
        VStack {
            VStack {
                Text("info_app_about_app_name")
                
                    .bold()
                    .font(.title2)
                    .padding(10)
                
                Text("info_app_about_version")
                    .padding(10)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("info_app_about_created_by", comment: "")
                    .multilineTextAlignment(.leading)
                    .padding(10)
                
                //!!NOTEz: info_app_about_oss_credits will be reduced or go away
                Text("info_app_about_oss_credits", comment: "")
                    .multilineTextAlignment(.leading)
                    .padding(10)
                
                Text("info_app_about_translators", comment: "")
                    .multilineTextAlignment(.leading)
                    .padding(10)
            }
        }
        .foregroundStyle(.nfText)
        .background(.white)
        .cornerRadius(5)
        .padding(10)
    }
}

#Preview {
    DailyDozenAboutCreditView()
}
