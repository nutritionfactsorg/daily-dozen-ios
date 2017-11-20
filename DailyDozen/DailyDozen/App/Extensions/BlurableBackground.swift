//
//  BlurableBackground.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 20.11.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

/// Provides a blurring effect.
protocol BlurableBackground {
    /// Applies a blurring effect to the parent view layer.
    func blurBackground()
    /// Removes a blurring effect from the parent view layer.
    func unblurBackground()
}

extension BlurableBackground where Self: UIViewController {

    func blurBackground() {
        guard let parentView = presentingViewController?.view else { return }
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.9
        blurEffectView.frame = parentView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 100
        parentView.addSubview(blurEffectView)
    }

    func unblurBackground() {
        guard let parentView = presentingViewController?.view else { return }
        for view in parentView.subviews {
            if let blurView = view as? UIVisualEffectView, blurView.tag == 100 {
                blurView.removeFromSuperview()
            }
        }
    }
}
