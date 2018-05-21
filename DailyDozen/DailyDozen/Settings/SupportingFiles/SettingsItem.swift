//
//  SettingsItem.swift
//  DailyDozen
//
//  Created by Lammert Westerhoff on 21/05/2018.
//  Copyright © 2018 Nutritionfacts.org. All rights reserved.
//

import UIKit

enum SettingsItem: Int {

    case settings, backup

    var controller: UIViewController? {
        switch self {
        case .settings:
            return ReminderBuilder.instantiateController()
        case .backup:
            return nil
        }
    }
}
