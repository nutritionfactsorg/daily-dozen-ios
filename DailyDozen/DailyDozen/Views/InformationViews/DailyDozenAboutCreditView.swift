//
//  DailyDozenAboutThanksView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct DailyDozenAboutCreditView: View {
    var body: some View {
        
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("info_app_about_app_name")
                    .bold()
                    .font(.title2)
                //.padding(.horizontal, 10)
                
                Text("info_app_about_version")
                    .font(.body)
                //.padding(.horizontal, 10)
            }
            VStack(alignment: .leading, spacing: 16) {
                Text("info_app_about_created_by", comment: "")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                //.padding(.horizontal, 10)
                
                //!!NOTEz: info_app_about_oss_credits will be reduced or go away
                Text("info_app_about_oss_credits", comment: "")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                //.padding(.horizontal, 10)
                
                Text("info_app_about_translators", comment: "")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                //.padding(.horizontal, 10)
            }
        }
        .foregroundStyle(.nfText)
        //.background(.white)
        //.cornerRadius(5)
        //.padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)  // Full width + leading
        .padding(.horizontal, 20)                         // Matches first card exactly
        .padding(.vertical, 10)
    }
}

#Preview {
    DailyDozenAboutCreditView()
}
