//
//  ItemHistoryViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 16.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import FSCalendar

class ItemHistoryBuilder {

    // MARK: - Nested
    private struct Keys {
        static let storyboard = "ItemHistory"
        static let cell = "DateCell"
    }

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Parameter title: An item name.
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController(with title: String, itemId: Int) -> UIViewController {
        let storyboard = UIStoryboard(name: Keys.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? ItemHistoryViewController
            else { fatalError("There should be a controller") }
        viewController.title = title
        viewController.itemId = itemId

        return viewController
    }
}

class ItemHistoryViewController: UIViewController {

    private struct Keys {
        static let cell = "DateCell"
    }

    private let realm = RealmProvider()
    var itemId = 0

    @IBOutlet weak var calendarView: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.register(DateCell.self, forCellReuseIdentifier: Keys.cell)
    }
}

extension ItemHistoryViewController: FSCalendarDataSource {

    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        guard
            let cell = calendar
                .dequeueReusableCell(withIdentifier: Keys.cell, for: date, at: .current) as? DateCell
            else { fatalError() }

        let states = realm.getDoze(for: date).items[itemId].states
        let selectedStates = states.filter { $0 }

        if selectedStates.count == states.count {
            cell.borderColor = UIColor.green
        } else if selectedStates.count > 0 {
            cell.borderColor = UIColor.yellow.withAlphaComponent(0.7)
        } else {
            cell.borderColor = UIColor.white
        }

        return cell
    }
}

extension ItemHistoryViewController: FSCalendarDelegate {
}
