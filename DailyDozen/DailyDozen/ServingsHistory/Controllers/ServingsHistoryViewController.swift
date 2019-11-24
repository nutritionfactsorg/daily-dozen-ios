//
//  ServingsHistoryViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 22.11.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

// MARK: - Nested
enum TimeScale: Int {
    case day, month, year
}

class ServingsHistoryBuilder {

    // MARK: - Nested
    private struct Strings {
        static let storyboard = "ServingsHistory"
    }

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> ServingsHistoryViewController {
        let storyboard = UIStoryboard(name: Strings.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? ServingsHistoryViewController
            else { fatalError("Did not instantiate `ServingsHistory` controller") }
        viewController.title = "Servings History"

        return viewController
    }
}

class ServingsHistoryViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var chartView: ChartView!
    @IBOutlet private weak var controlPanel: ControlPanel!
    @IBOutlet private weak var scaleControl: UISegmentedControl!

    // MARK: - Properties
    private var viewModel: ServingsHistoryViewModel!
    private var currentTimeScale = TimeScale.day

    private var chartSettings: (year: Int, month: Int)! {
        didSet {
            chartView.clear()

            if currentTimeScale == .day {
                controlPanel.isHidden = false
                controlPanel.superview?.isHidden = false

                var canLeft = true
                if chartSettings.month == 0, chartSettings.year == 0 {
                    canLeft = false
                }

                var canRight = true

                if chartSettings.year == viewModel.lastYearIndex,
                    chartSettings.month == viewModel.lastMonthIndex(for: viewModel.lastYearIndex) {
                    canRight = false
                }

                controlPanel.configure(canSwitch: (left: canLeft, right: canRight))

                let data = viewModel.monthData(yearIndex: chartSettings.year, monthIndex: chartSettings.month)

                controlPanel.setLabels(month: data.month, year: viewModel.yearName(yearIndex: chartSettings.year))

                chartView.configure(with: data.map, for: currentTimeScale)
            } else if currentTimeScale == .month {
                controlPanel.isHidden = false
                controlPanel.superview?.isHidden = false

                let canLeft = chartSettings.year != 0
                let canRight = chartSettings.year != viewModel.lastYearIndex
                controlPanel.configure(canSwitch: (left: canLeft, right: canRight))

                let data = viewModel.yearlyData(yearIndex: chartSettings.year)

                controlPanel.setLabels(year: data.year)

                chartView.configure(with: data.map, for: currentTimeScale)
            } else {
                controlPanel.isHidden = true
                controlPanel.superview?.isHidden = true
                chartView.configure(with: viewModel.fullDataMap(), for: currentTimeScale)
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
        let realm = RealmProviderLegacy()

        let results: Results<Doze> = realm
            .getDozes()
            .sorted(byKeyPath: "date")
        guard results.count > 0 else {
            controlPanel.isHidden = true
            scaleControl.isEnabled = false
            controlPanel.superview?.isHidden = true
            return
        }

        viewModel = ServingsHistoryViewModel(results)
        let lastYearIndex = viewModel.lastYearIndex

        chartSettings = (lastYearIndex, viewModel.lastMonthIndex(for: lastYearIndex))
    }

    // MARK: - Actions
    @IBAction private func toFirstButtonPressed(_ sender: UIButton) {
        chartSettings = (0, 0)
    }

    @IBAction private func toPreviousButtonPressed(_ sender: UIButton) {
        if chartSettings.month > 0 && currentTimeScale == .day {
            chartSettings.month -= 1
        } else if chartSettings.year > 0 {
            let year = chartSettings.year - 1
            let month = viewModel.lastMonthIndex(for: year)
            chartSettings = (year, month)
        }
    }

    @IBAction private func toNextButtonPressed(_ sender: UIButton) {
        if chartSettings.month < viewModel.lastMonthIndex(for: chartSettings.year) && currentTimeScale == .day {
            chartSettings.month += 1
        } else if chartSettings.year < viewModel.lastYearIndex {
            let year = chartSettings.year + 1
            let month = 0
            chartSettings = (year, month)
        }
    }

    @IBAction private func toLastButtonPressed(_ sender: UIButton) {
        let lastYearIndex = viewModel.lastYearIndex
        chartSettings = (lastYearIndex, viewModel.lastMonthIndex(for: lastYearIndex))
    }

    @IBAction private func timeScaleChanged(_ sender: UISegmentedControl) {
        guard let timeScale = TimeScale(rawValue: sender.selectedSegmentIndex) else { return }
        currentTimeScale = timeScale

        switch currentTimeScale {
        case .day:
            let lastYearIndex = viewModel.lastYearIndex
            chartSettings = (lastYearIndex, viewModel.lastMonthIndex(for: lastYearIndex))
        case .month:
            let lastYearIndex = viewModel.lastYearIndex
            chartSettings = (lastYearIndex, 0)
        case .year:
            chartSettings = (0, 0)
        }
    }
}

// MARK: - IAxisValueFormatter
extension ServingsHistoryViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let labels: [String]
        if currentTimeScale == .day {
            labels = viewModel.datesLabels(yearIndex: chartSettings.year, monthIndex: chartSettings.month)
        } else if currentTimeScale == .month {
            labels = viewModel.monthsLabels(yearIndex: chartSettings.year)
        } else {
            labels = viewModel.fullDataLabels()
        }
        let index = Int(value)
        guard index < labels.count else { return "" }
        return labels[index]
    }
}
