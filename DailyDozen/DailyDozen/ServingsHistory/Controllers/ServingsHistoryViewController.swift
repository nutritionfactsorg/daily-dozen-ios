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
    @IBOutlet private weak var controlPanel: ControlPanel!

    // MARK: - Properties
    private var viewModel: ServingsHistoryViewModel!
    private var currentTimeScale = TimeScale.day

    private var pageCodes: (year: Int, month: Int)! {
        didSet {
            chartView.clear()

            if currentTimeScale == .day {
                let canLeft = pageCodes.month > 0
                let canRight = pageCodes.month < viewModel.lastMonthIndex(for: viewModel.lastYearIndex)
                controlPanel.configure(canSwitch: (left: canLeft, right: canRight))

                let data = viewModel.monthData(yearIndex: pageCodes.year, monthIndex: pageCodes.month)

                controlPanel.setLabels(month: data.month, year: "2017")

                chartView.configure(with: data.map, for: currentTimeScale)
            } else {
                let canLeft = false
                let canRight = false
                controlPanel.configure(canSwitch: (left: canLeft, right: canRight))

                let data = viewModel.yearlyData(yearIndex: pageCodes.year)

                controlPanel.setLabels(year: data.year)

                chartView.configure(with: data.map, for: currentTimeScale)
            }
        }
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        chartView.xAxis.valueFormatter = self
        setViewModel()
    }

    // MARK: - Methods
    private func setViewModel() {
        let realm = RealmProvider()

        let results = realm
            .getDozes()
            .sorted(byKeyPath: "date")

        viewModel = ServingsHistoryViewModel(results)
        let lastYearIndex = viewModel.lastYearIndex

        pageCodes = (lastYearIndex, viewModel.lastMonthIndex(for: lastYearIndex))
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
        guard pageCodes.month < viewModel.lastMonthIndex(for: viewModel.lastYearIndex) else { return }
        pageCodes.month += 1
    }

    @IBAction private func toLastButtonPressed(_ sender: UIButton) {
        pageCodes.month = viewModel.lastMonthIndex(for: viewModel.lastYearIndex)
    }

    @IBAction private func timeScaleChanged(_ sender: UISegmentedControl) {
        guard let timeScale = TimeScale(rawValue: sender.selectedSegmentIndex) else { return }
        currentTimeScale = timeScale

        switch currentTimeScale {
        case .day:
            let lastYearIndex = viewModel.lastYearIndex
            pageCodes = (lastYearIndex, viewModel.lastMonthIndex(for: lastYearIndex))
            break
        case .month:
            let lastYearIndex = viewModel.lastYearIndex
            pageCodes = (lastYearIndex, 0)
            break
        case .year:
            break
        }
    }
}

// MARK: - IAxisValueFormatter
extension ServingsHistoryViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let labels: [String]
        if currentTimeScale == .day {
            labels = viewModel.datesLabels(yearIndex: pageCodes.year, monthIndex: pageCodes.month)
        } else {
            labels = viewModel.monthsLabels(yearIndex: pageCodes.year)
        }
        let index = Int(value)
        guard index < labels.count else { return "" }
        return labels[index]
    }
}
