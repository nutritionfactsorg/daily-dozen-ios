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
    private let realm = RealmProvider.primary
    fileprivate var itemType: DataCountType!

    // MARK: - Outlets
    @IBOutlet private weak var calendarView: FSCalendar!
    @IBOutlet weak var itemHistoryFooter: UIView!
    @IBOutlet weak var itemHistoryFooterAll: UILabel!
    @IBOutlet weak var itemHistoryFooterSome: UILabel!
    @IBOutlet weak var itemHistoryHeader: UIView!
    @IBOutlet weak var itemHistoryHeaderLabel: UILabel!
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = ColorManager.style.mainMedium
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // Multiline title to resolve "< Back" localization issue
        setUpMultiLineTitle()
        
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.register(DateCell.self, forCellReuseIdentifier: Strings.cell)
        
        itemHistoryFooter.backgroundColor = ColorManager.style.mainMedium
        itemHistoryHeader.backgroundColor = ColorManager.style.mainMedium
        itemHistoryHeaderLabel.textColor = ColorManager.style.textWhite
        
        itemHistoryHeaderLabel.text = NSLocalizedString("item_history_heading", comment: "History")
        itemHistoryFooterAll.text = NSLocalizedString("item_history_completed_all", comment: "All completed")
        itemHistoryFooterSome.text = NSLocalizedString("item_history_completed_some", comment: "Some completed")
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
            cell.configure(for: statesCount, maximum: itemType.goalServings)
        } else {
            cell.configure(for: 0, maximum: itemType.goalServings)
        }
        
        return cell
    }
}

// MARK: - FSCalendarDelegate
extension ItemHistoryViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // logit.debug(":DEBUG: selected date \(date)")
        
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

// MARK: - Multiline Title
extension ItemHistoryViewController {
    
    // Resolves "< Back" localization issue by avoiding the conditions
    // in which "Back" is auto-inserted by the iOS system.
    //
    // The core issue is that iOS which does not localize "Back" for
    // all languages which the iPhone supports. And, the developer
    // is not otherwise provided access to localize or to override
    // the auto-inserted "Back".
    //
    // "Back" is autogenerated by the iOS system when for certain 
    // in-between-length titles from the previous page. The "Back" 
    // localization issue is avoided by switching the title from 
    // a single line to a multliline title.
    // 
    
    func setUpMultiLineTitle() {
        let wrapperView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.75, height: 44))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.75, height: 44))
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.font = UIFont.fontSystemBold18
        
        label.textAlignment = .center
        label.textColor = ColorManager.style.textWhite
        label.text = title
        wrapperView.addSubview(label)
        self.navigationItem.titleView = wrapperView
    }
    
}
