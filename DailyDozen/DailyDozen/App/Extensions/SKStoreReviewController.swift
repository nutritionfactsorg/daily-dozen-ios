//
//  SKStoreReviewController.swift
//  DailyDozen
//
//  Copyright © 2023 Nutritionfacts.org. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

// :SwiftUI:Upgrade:
//private struct ContentView: View {
//    @Environment(\.requestReview) private var requestReview
//
//    var body: some View {
//        Button("Review") {
//            DispatchQueue.main.async {
//                requestReview()
//            }
//        }
//    }
//}

extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                requestReview(in: scene)
            }
        }
    }
}
