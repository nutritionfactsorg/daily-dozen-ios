//
//  PagerViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PagerViewController: ButtonBarPagerTabStripViewController {

    // MARK: - PagerTabStripDataSource
    override func viewControllers(
        for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        return [ServingsViewController()]
    }
}
