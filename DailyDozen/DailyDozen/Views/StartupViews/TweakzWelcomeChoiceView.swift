//
//  TweakzWelcomeChoiceView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct TweakzWelcomeChoiceView: View {
    @AppStorage(wrappedValue: false, SettingsKeys.show21TweaksPref)
    private var show21Tweaks: Bool
    
    @AppStorage(SettingsKeys.hasSeenLaunchV4) private var hasSeenTweaks = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        VStack(spacing: dynamicTypeSize.isAccessibilitySize ? 8 : 0) {
            // Header
            HStack {
                Text("navtab.doze")
                    .font(dynamicTypeSize.isAccessibilitySize ? .headline.bold() : .title2.bold())
                    .dynamicTypeSize(.small ... .accessibility2)  // Cap header
                    .foregroundColor(.black) // •TBDz•color•
                
                Spacer()
            }
            .padding(dynamicTypeSize.isAccessibilitySize ? 12 : 20)
            .background(Color.nfGreenBrand.opacity(0.1))
            .clipShape(
                dynamicTypeSize.isAccessibilitySize
                ? UnevenRoundedCorners(radius: 8, corners: [.bottomLeft, .bottomRight])
                : UnevenRoundedCorners(radius: 20, corners: [.bottomLeft, .bottomRight])
            )
            
            // Main content
            VStack(spacing: dynamicTypeSize.isAccessibilitySize ? 12 : 32) {
                Text("setting_health_alone_txt")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .dynamicTypeSize(.small ... .accessibility2)  // Cap header
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? 24 : 40)
                
                    Button {
                        show21Tweaks = false
                        hasSeenTweaks = true
                        dismiss()
                    } label: {
                        Text("setting_doze_only_btn")
                            .bold()
                            .dynamicTypeSize(.small ... .accessibility2)
                            .multilineTextAlignment(.center)
                            .lineLimit(4)  // Increased — handles even very long locales
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.nfGreenBrand)  // Forces prominent style to use NF green
                    .controlSize(.large)
                    
                    Text("setting_health_weight_txt")
                        .dynamicTypeSize(.small ... .accessibility2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)  // Critical for no truncation
                    
                    Button {
                        show21Tweaks = true
                        hasSeenTweaks = true
                        dismiss()
                    } label: {
                        Text("setting_doze_tweak_btn")
                            .bold()
                            .dynamicTypeSize(.small ... .accessibility2)
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)   // Change from .bordered to .borderedProminent
                    .tint(.nfGreenBrand)
                    .controlSize(.large)
                    
                // Optional footer note (uncomment if desired)
                // Text("You can always change this later in Preferences")
                //     .font(.caption)
                //     .foregroundColor(.secondary)
                //     .padding(.top, 20)
            }
            .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? 24 : 40)
            .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 16 : 32)
             Spacer(minLength: 0)  // Pushes everything up if extra space
        }
        .background(Color.nfGreenBrand.opacity(0.1)) // Subtle background if needed
        .cornerRadius(dynamicTypeSize.isAccessibilitySize ? 12 : 16)
        .shadow(radius: 20)
        .padding(dynamicTypeSize.isAccessibilitySize ? 16 : 40)
        .padding(.top, dynamicTypeSize.isAccessibilitySize ? 30 : 12)
        .background(Color.clear) // Ensures padding doesn't affect shadow
    }
}

struct UnevenRoundedCorners: Shape {
    var radius: CGFloat = .zero
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
