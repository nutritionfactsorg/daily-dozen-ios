//
//  Choose21TweaksView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct WelcomeTweaksChoiceView: View {
    @AppStorage(wrappedValue: false, SettingsKeys.show21TweaksPref)
    private var show21Tweaks: Bool
    
    @AppStorage(SettingsKeys.hasSeenLaunchV4) private var hasSeenTweaks = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("navtab.doze")
                    .font(.title2.bold())
                    .foregroundColor(.black) // :TBDz:color:
                
                Spacer()
            }
            .padding()
            .clipShape(
                UnevenRoundedCorners(radius: 20, corners: [.bottomLeft, .bottomRight])
            )
            
            // Main content
            VStack(spacing: 32) {
                Text("setting_health_alone_txt")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
                
                VStack(spacing: 16) {
                    Button {
                        show21Tweaks = false
                        hasSeenTweaks = true
                        dismiss()
                    } label: {
                        Text("setting_doze_only_btn")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.nfGreenBrand)  // Forces prominent style to use your green
                    
                    Text("setting_health_weight_txt")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        show21Tweaks = true
                        hasSeenTweaks = true
                        dismiss()
                    } label: {
                        Text("setting_doze_tweak_btn")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)   // Change from .bordered to .borderedProminent
                    .tint(.nfGreenBrand)
                }
                .controlSize(.large)
                .padding(.horizontal, 40)
                
                // Optional footer note (uncomment if desired)
                // Text("You can always change this later in Preferences")
                //     .font(.caption)
                //     .foregroundColor(.secondary)
                //     .padding(.top, 20)
            }
            .padding(.vertical, 32)
        }
        .background(Color.nfGreenBrand.opacity(0.1)) // Subtle background if needed
        .cornerRadius(16)
        .shadow(radius: 20)
        .padding(40)
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
