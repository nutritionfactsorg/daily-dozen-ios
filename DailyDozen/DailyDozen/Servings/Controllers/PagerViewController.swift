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

    let selectedColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)

    override func viewDidLoad() {

        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = selectedColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0

        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.selectedColor
        }

        pagerBehaviour = .common(skipIntermediateViewControllers: true)

        super.viewDidLoad()
    }

    // MARK: - PagerTabStripDataSource
    override func viewControllers(
        for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        let controller1 = ServingsBuilder.instantiateController(with: "1")
        let controller2 = ServingsBuilder.instantiateController(with: "2")
        let controller3 = ServingsBuilder.instantiateController(with: "3")

        let childViewControllers = [controller1, controller2, controller3]

        return childViewControllers
    }
}
