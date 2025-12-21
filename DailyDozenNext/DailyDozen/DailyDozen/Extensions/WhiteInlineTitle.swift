//
//  WhiteInlineTitle.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct WhiteInlineTitle: ViewModifier {
    let titleKey: LocalizedStringKey  // Accept either a static key OR a dynamic localized String
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.nfGreenBrand, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(titleKey)
                        .foregroundStyle(.white)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .tracking(-0.4)           // optional but pixel-perfect
                }
            }
            // Keep the original for accessibility / Dynamic Type / future large-title use
            .navigationTitle(titleKey)
    }
}

// MARK: - Public extensions (two overloads)
extension View {
    /// Use this when you have a plain String (dynamic, computed, from model, etc.)
    func whiteInlineGreenTitle(_ title: String) -> some View {
        self.modifier(WhiteInlineTitle(titleKey: LocalizedStringKey(title)))
    }
    
    /// Use this when you have a literal localized key like "navtab.settings"
    func whiteInlineGreenTitle(_ titleKey: LocalizedStringKey) -> some View {
        self.modifier(WhiteInlineTitle(titleKey: titleKey))
    }
}
