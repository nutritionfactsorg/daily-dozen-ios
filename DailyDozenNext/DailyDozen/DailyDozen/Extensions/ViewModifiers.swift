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
