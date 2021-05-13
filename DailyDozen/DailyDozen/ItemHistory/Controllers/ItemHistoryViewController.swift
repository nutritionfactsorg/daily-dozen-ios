//
//  ItemHistoryViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 16.11.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import FSCalendar

class ItemHistoryViewController: UIViewController {

    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Parameter heading: An item display heading.
    /// - Returns: The initial item histor view controller in the storyboard.
    static func newInstance(heading: String, itemType: DataCountType) -> UIViewController {
        let storyboard = UIStoryboard(name: "ItemHistoryLayout", bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? ItemHistoryViewController
            else { fatalError("Did not instantiate `ItemHistoryViewController`") }
        viewController.title = heading
        viewController.itemType = itemType

        return viewController
    }

    // MARK: - Nested
    private struct Strings {
        static let cell = "DateCell"
    }

    // MARK: - Properties
    private let realm = RealmProvider()
    fileprivate var itemType: DataCountType!

    // MARK: - Outlets
    @IBOutlet private weak var calendarView: FSCalendar!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = ColorManager.style.mainMedium
        navigationController?.navigationBar.tintColor = UIColor.white

        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.register(DateCell.self, forCellReuseIdentifier: Strings.cell)
    }
}

// MARK: - FSCalendarDataSource
extension ItemHistoryViewController: FSCalendarDataSource {

    func maximumDate(for calendar: FSCalendar) -> Date {
        return DateManager.currentDatetime()
    }

    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        guard
            let cell = calendar
                .dequeueReusableCell(withIdentifier: Strings.cell, for: date, at: .current) as? DateCell
            else { fatalError("There should be a cell") }

        guard date < DateManager.currentDatetime() else { return cell }

        let itemsDict = realm.getDailyTracker(date: date).itemsDict
        if let statesCount = itemsDict[itemType]?.count {
            cell.configure(for: statesCount, maximum: itemType.maxServings)
        } else {
            cell.configure(for: 0, maximum: itemType.maxServings)
        }
        
        return cell
    }
}

// MARK: - FSCalendarDelegate
extension ItemHistoryViewController: FSCalendarDelegate {

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // print(":DEBUG: selected date \(date)")
        
        if let vc = navigationController?.viewControllers[1] {  
            // <Array<UIViewController>>
            // [0] : DailyDozen.DozeEntryPagerViewController
            // [1] : DailyDozen.ItemHistoryViewController
            // :???: needs [0] to be *EntryPagerViewController.

            if let viewController = vc as? DozeEntryPagerViewController {
                viewController.updatePageDate(date)
                navigationController?.popViewController(animated: true)
                // :???: if [0] does not return to calendar selected date
            } else if let viewController = vc as? TweakEntryPagerViewController {
                viewController.updatePageDate(date)
                navigationController?.popViewController(animated: true) 
            }
            
        }
    }
}
