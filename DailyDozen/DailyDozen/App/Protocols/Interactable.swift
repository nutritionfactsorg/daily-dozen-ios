//
//  Interactable.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 15.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation

/// Protocol allow the delegate to manage taps, selections, etc.
protocol Interactable: class {
    /// Tells the delegate that the view was selected.
    func viewDidTap()
}
