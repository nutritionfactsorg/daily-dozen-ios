//
//  ViewModifier.swift
//  DailyDozen
//
//  Created by mc on 3/12/25.
//

import SwiftUI

struct ShadowBox: ViewModifier {
  
  func body(content: Content) -> some View {
    
content
            .background(.white)
            .cornerRadius(5)
            .shadow(radius: 5)
           // .background(Color(.systemBackground))
            //TBDz check color
            .shadow(color: .nfGray50.opacity(1.0), radius: 5, x: 1, y: 1)
            .padding(5)
  }
}
extension View {
  func shadowboxed() -> some View {
    modifier(ShadowBox())
  }
}

// ViewModifier for chartXScale
struct ChartXScaleModifier: ViewModifier {
    let domain: ClosedRange<Date>?
    
    func body(content: Content) -> some View {
        if let domain = domain {
            content.chartXScale(domain: domain)
        } else {
            content
        }
    }
}

// Extension to make the modifier easily accessible
extension View {
    func applyChartXScale(domain: ClosedRange<Date>?) -> some View {
        modifier(ChartXScaleModifier(domain: domain))
    }
}

//Custom modifier for iOS 16/17 compatibility
//struct OnChangeDateModifier: ViewModifier {
//    let date: Date
//    let action: (Date) -> Void
//    
//    @ViewBuilder
//    func body(content: Content) -> some View {
//        if #available(iOS 17.0, *) {
//            content
//                .onChange(of: date, initial: true) { _, newValue in
//                    action(newValue)
//                }
//        } else {
//            content
//                .onChange(of: date) { newValue in
//                    action(newValue)
//                }
//                .onAppear {
//                    action(date)
//                }
//        }
//    }
//}
