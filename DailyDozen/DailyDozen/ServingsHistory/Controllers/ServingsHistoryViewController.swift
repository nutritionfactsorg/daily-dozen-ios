//
//  ServingsHistoryViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 22.11.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import Charts

// MARK: - Nested
enum TimeScale: Int {
    case day, month, year
}

class ServingsHistoryBuilder {

    // MARK: - Nested
    private struct Keys {
        static let storyboard = "ServingsHistory"
    }

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> ServingsHistoryViewController {
        let storyboard = UIStoryboard(name: Keys.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? ServingsHistoryViewController
            else { fatalError("There should be a controller") }
        viewController.title = "Servings History"

        return viewController
    }
}

class ServingsHistoryViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var chartView: ChartView!
    @IBOutlet private weak var monthLabel: UILabel! {
        didSet {
            monthLabel.text = Date().monthName
        }
    }

    @IBOutlet private weak var toFirstButton: RoundedButton!
    @IBOutlet private weak var toPreviousButton: RoundedButton!
    @IBOutlet private weak var toNextButton: RoundedButton!
    @IBOutlet private weak var toLastButton: RoundedButton!

    // MARK: - Properties
    private var report: Report!

    private var pageCodes: (year: Int, month: Int)! {
        didSet {
            chartView.clear()

            toFirstButton.isEnabled = pageCodes.month > 0
            toPreviousButton.isEnabled = pageCodes.month > 0
            toNextButton.isEnabled = pageCodes.month < report.data.last!.months.count - 1
            toLastButton.isEnabled = pageCodes.month < report.data.last!.months.count - 1

            monthLabel.text = report.data[pageCodes.year].months[pageCodes.month].month
            let map = report.data[pageCodes.year].months[pageCodes.month].daily.map { $0.statesCount }
            chartView.configure(with: map, for: currentTimeScale)
        }
    }
    private var currentTimeScale = TimeScale.day

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        chartView.xAxis.valueFormatter = self
        loadData()
    }

    // MARK: - Methods
    private func loadData() {
        let realm = RealmProvider()

        let result = realm
            .getDozes()
            .sorted(byKeyPath: "date")

        report = Report(Array(result))
        pageCodes = (report.data.count - 1, report.data.last!.months.count - 1)
    }

    // MARK: - Actions
    @IBAction private func toFirstButtonPressed(_ sender: UIButton) {
        pageCodes.month = 0
    }

    @IBAction private func toPreviousButtonPressed(_ sender: UIButton) {
        guard pageCodes.month > 0 else { return }
        pageCodes.month -= 1
    }

    @IBAction private func toNextButtonPressed(_ sender: UIButton) {
        let count = report.data.last!.months.count
        guard pageCodes.month < count - 1 else { return }
        pageCodes.month += 1
    }

    @IBAction private func toLastButtonPressed(_ sender: UIButton) {
        pageCodes.month = report.data.last!.months.count - 1
    }

    @IBAction private func timeScaleChanged(_ sender: UISegmentedControl) {
        guard let timeScale = TimeScale(rawValue: sender.selectedSegmentIndex) else { return }
        currentTimeScale = timeScale

        switch currentTimeScale {
        case .day:
            break
        case .month:
            break
        case .year:
            break
        }
    }
}

// MARK: - IAxisValueFormatter
extension ServingsHistoryViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let days = report.data[pageCodes.year].months[pageCodes.month].daily.map { $0.date }
        guard Int(value) < days.count else { return ""}
        let day = days[Int(value)]
        return "\(day.day) \n \(day.monthName)"
    }
}
