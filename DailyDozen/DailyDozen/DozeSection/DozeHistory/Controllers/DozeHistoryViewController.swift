//
//  DozeHistoryViewController.swift
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
    
    func toString() -> String {
        switch self {
        case .day:
            return "day"
        case .month:
            return "day"
        case .year:
            return "year"
        }
    }
}

/// Historic record of daily checkbox tally.
class DozeHistoryViewController: UIViewController {

    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func newInstance() -> DozeHistoryViewController {
        let storyboard = UIStoryboard(name: "DozeHistoryLayout", bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? DozeHistoryViewController
            else { fatalError("Did not instantiate `DozeHistoryViewController`") }
        viewController.title = NSLocalizedString("historyRecordDoze.heading", comment: "Servings History")

        return viewController
    }

    // MARK: - Outlets
    @IBOutlet private weak var chartView: ChartView!
    @IBOutlet private weak var controlPanel: ControlPanel!
    @IBOutlet private weak var scaleControl: UISegmentedControl!
    @IBOutlet weak var scaleLabel: UILabel!
    
    // MARK: - Properties
    private var viewModel: DozeHistoryViewModel!
    private var currentTimeScale = TimeScale.day

    private var chartSettings: (year: Int, month: Int)! {
        didSet {
            chartView.clear()

            let legendServingsText = NSLocalizedString("historyRecordDoze.legend", comment: "Servings")
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

                chartView.configure(with: data.map, for: currentTimeScale, label: legendServingsText)
            } else if currentTimeScale == .month {
                controlPanel.isHidden = false
                controlPanel.superview?.isHidden = false

                let canLeft = chartSettings.year != 0
                let canRight = chartSettings.year != viewModel.lastYearIndex
                controlPanel.configure(canSwitch: (left: canLeft, right: canRight))

                let data = viewModel.yearlyData(yearIndex: chartSettings.year)

                controlPanel.setLabels(year: data.year)

                chartView.configure(with: data.map, for: currentTimeScale, label: legendServingsText)
            } else {
                controlPanel.isHidden = true
                controlPanel.superview?.isHidden = true
                chartView.configure(with: viewModel.fullDataMap(), for: currentTimeScale, label: legendServingsText)
            }
        }
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white
        
        scaleControl.setTitle(NSLocalizedString("history_scale_choice_day", comment: "Day"), forSegmentAt: 0)
        scaleControl.setTitle(NSLocalizedString("history_scale_choice_month", comment: "Month"), forSegmentAt: 1)
        scaleControl.setTitle(NSLocalizedString("history_scale_choice_year", comment: "Year"), forSegmentAt: 2)
        scaleLabel.text = NSLocalizedString("history_scale_label", comment: "Time Scale")
        
        chartView.xAxis.valueFormatter = self
        setViewModel()
    }

    // MARK: - Methods
    private func setViewModel() {
        let realm = RealmProvider()

        let trackers: [DailyTracker] = realm.getDailyTrackers()
        guard trackers.count > 0 else {
            controlPanel.isHidden = true
            scaleControl.isEnabled = false
            controlPanel.superview?.isHidden = true
            return
        }

        viewModel = DozeHistoryViewModel(trackers)
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
extension DozeHistoryViewController: IAxisValueFormatter {

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
