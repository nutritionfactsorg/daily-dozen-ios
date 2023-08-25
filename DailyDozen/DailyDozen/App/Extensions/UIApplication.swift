//
//  UIApplication.swift
//  DailyDozen
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import UIKit

extension UIApplication {

    /// The app's key window taking into consideration apps that support multiple scenes.
    var keyWindowInConnectedScenes: UIWindow? {
        // A key window receives keyboard and other non-touch related events.
        // Only one window at a time may be the key window.
        let windowScenes: [UIWindowScene] = connectedScenes.compactMap({ $0 as? UIWindowScene })
        let windows: [UIWindow] = windowScenes.flatMap({ $0.windows })
        return windows.first(where: { $0.isKeyWindow })
    }

    func topViewController() -> UIViewController? {
        let windowScenes: [UIWindowScene] = connectedScenes.compactMap({ $0 as? UIWindowScene })
        let windows: [UIWindow] = windowScenes.flatMap({ $0.windows })
        let keyWindow = windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
            
        } else {
            
            return nil
            
        }
        
    }
    
}
