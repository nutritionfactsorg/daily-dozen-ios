//
//  InfoFaqTableView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct FaqCustomDisclosureGroupStyle<Label: View>: DisclosureGroupStyle {
    let button: Label
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            button
                .rotationEffect(.degrees(configuration.isExpanded ? 180 : 0))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                configuration.isExpanded.toggle()
            }
        }
        if configuration.isExpanded {
            configuration.content
                .padding(.leading, 30)
                .disclosureGroupStyle(self)
        }
    }
}

struct FaqModel: Identifiable {
    let id = UUID()
    var title: String
    var details: String
}

struct InfoFaqTableView: View {
    
//    let faqsWAS: [FaqModel] = [FaqModel(title: "faq_adapt_question", details: "faq_adapt_response"),
//                       FaqModel( title: "faq_age_question", details: "faq_age_response.0")]
    let faqsList: [FaqModel] = [FaqModel(title: String(localized: "faq_adapt_question"), details: String(localized: "faq_adapt_response")),
                               FaqModel( title: String(localized: "faq_age_question"), details: String(localized: "faq_age_response.0", comment: "")
                                         + "\n\n" + String(localized: "faq_age_response.1", comment: "")),
                               FaqModel(title: String(localized: "faq_calories_question", comment: ""), details: String(localized: "faq_calories_response.0", comment: "")
                                        + "\n\n" + String(localized: "faq_calories_response.1", comment: "")
                                        + "\n\n" + String(localized: "faq_calories_response.2", comment: "")),
                               FaqModel(title: String(localized: "faq_mother_question", comment: ""), details: String(localized: "faq_mother_response", comment: "")),
                               FaqModel(title: String(localized: "faq_scaling_question", comment: ""), details: String(localized: "faq_scaling_response", comment: "")),
                               FaqModel(title: String(localized: "faq_supplements_question", comment: ""), details: String(localized: "faq_supplements_response", comment: ""))
    ]
    // var faqList = FaqListBuild.self
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(faqsList) {
                    faq in
                    DisclosureGroup {
                      // Text(LocalizedStringKey(faq.details))
                        Text(faq.details)
                      
                    } label: {
                       // Text(LocalizedStringKey(faq.title))
                       Text(faq.title)
                            .fontWeight(.bold)
                    }
                }
            } //List
            .disclosureGroupStyle(FaqCustomDisclosureGroupStyle(button: Image(systemName: "chevron.down.square.fill").foregroundColor(.brandGreen)))
            .navigationTitle(Text("faq_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.brandGreen, for: .navigationBar)
        }
 
    }
  
}

#Preview {

    InfoFaqTableView()
     // .environment(\.locale, .init(identifier: "de"))
       
}
