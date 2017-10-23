//
//  PagerViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import BmoViewPager

class PagerViewController: UIViewController, BmoViewPagerDataSource, BmoViewPagerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var pagerNavigation: BmoViewPagerNavigationBar!
    @IBOutlet weak var viewPager: BmoViewPager!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        viewPager.dataSource = self
        viewPager.delegate = self
        viewPager.infinitScroll = true
        pagerNavigation.viewPager = viewPager
    }

    // MARK: - BmoViewPagerDataSource
    func bmoViewPagerDataSourceNumberOfPage(in viewPager: BmoViewPager) -> Int {
        return 1
    }

    func bmoViewPagerDataSource(_ viewPager: BmoViewPager, viewControllerForPageAt page: Int) -> UIViewController {
        return ServingsBuilder.instantiateController(with: String(page))
    }

    func bmoViewPagerDataSourceNaviagtionBarItemTitle(_ viewPager: BmoViewPager, navigationBar: BmoViewPagerNavigationBar, forPageListAt page: Int) -> String? {

        return String(page)
    }
}
