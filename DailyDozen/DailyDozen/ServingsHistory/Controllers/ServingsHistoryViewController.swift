//
//  ServingsHistoryViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 22.11.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import Charts

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

    // MARK: - Nested
    private enum TimeScale: Int {
        case day, month, year
    }

    // MARK: - Outlets
    @IBOutlet private weak var chartView: CombinedChartView! {
        didSet {
            chartView.chartDescription?.enabled = false
            chartView.drawBarShadowEnabled = false
            chartView.highlightFullBarEnabled = false
            chartView.setScaleEnabled(false)
            chartView.dragYEnabled = false

            chartView.drawOrder = [DrawOrder.bar.rawValue,
                                   DrawOrder.line.rawValue]

            let legend = chartView.legend
            legend.wordWrapEnabled = true
            legend.horizontalAlignment = .center
            legend.verticalAlignment = .bottom
            legend.orientation = .horizontal
            legend.drawInside = false

            let rightAxis = chartView.rightAxis
            rightAxis.axisMinimum = 0

            let leftAxis = chartView.leftAxis
            leftAxis.axisMinimum = 0

            let xAxis = chartView.xAxis
            xAxis.labelPosition = .bothSided
            xAxis.granularity = 1
            xAxis.valueFormatter = self
        }
    }
    @IBOutlet private weak var monthLabel: UILabel! {
        didSet {
            monthLabel.text = Date().monthName
        }
    }

    @IBOutlet weak var toFirstButton: RoundedButton!
    @IBOutlet weak var toPreviousButton: RoundedButton!
    @IBOutlet weak var toNextButton: RoundedButton!
    @IBOutlet weak var toLastButton: RoundedButton!

    // MARK: - Properties
    private var dozes = [String: [Doze]]()
    private var months = [String]()
    private var currentDozes = [Doze]() {
        didSet {
            chartView.clear()
            currentDate = currentDozes[0].date
            setChartData()
        }
    }
    private var currentDate = Date() {
        didSet {
            monthLabel.text = currentDate.monthName
            guard let index = months.index(of: currentDate.monthName) else { return }
            toFirstButton.isEnabled = index > 0
            toPreviousButton.isEnabled = index > 0
            toNextButton.isEnabled = index < months.count - 1
            toLastButton.isEnabled = index < months.count - 1
        }
    }
    private var currentTimeScale = TimeScale.day

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        loadDozes()

        guard
            let monthName = months.last,
            let newDozes = dozes[monthName]
            else { return }

        currentDozes = newDozes
    }

    // MARK: - Methods
    private func loadDozes() {
        let realm = RealmProvider()

        let result = realm
            .getDozes()
            .sorted(byKeyPath: "date")

        result.forEach { doze in
            if dozes[doze.date.monthName] == nil {
                dozes.updateValue([], forKey: doze.date.monthName)
                months.append(doze.date.monthName)
            }
            dozes[doze.date.monthName]?.append(doze)
        }
    }

    private func setChartData() {
        let data = CombinedChartData()
        data.barData = generateBarData(for: currentDozes)
        data.lineData = generateLineData(for: currentDozes)

        chartView.xAxis.axisMaximum = data.xMax + 0.5
        chartView.xAxis.axisMinimum = data.xMin - 0.5

        chartView.data = data

        chartView.setVisibleXRange(minXRange: 3, maxXRange: 7)
        chartView.moveViewToX(Double(currentDozes.count))

        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
        chartView.setNeedsDisplay()
    }

    private func generateBarData(for dozes: [Doze]) -> BarChartData {

        var entries = [BarChartDataEntry]()

        for (index, doze) in dozes.enumerated() {
            var statesCount = 0
            for item in doze.items {
                let selectedStates = item.states.filter { $0 }
                statesCount += selectedStates.count
            }
            entries.append(BarChartDataEntry(x: Double(index), y: Double(statesCount)))
        }

        let set = BarChartDataSet(values: entries, label: "Servings")
        let green = UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1)
        set.setColor(green)
        set.valueTextColor = green
        set.valueFont = .systemFont(ofSize: 10)
        set.axisDependency = .left

        let data = BarChartData(dataSet: set)

        return data
    }

    private func generateLineData(for dozes: [Doze]) -> LineChartData {

        var entries = [ChartDataEntry]()

        for (index, doze) in dozes.enumerated() {
            var statesCount = 0
            for item in doze.items {
                let selectedStates = item.states.filter { $0 }
                statesCount += selectedStates.count
            }
            let fakeY = Double(statesCount) / 3.0
            entries.append(ChartDataEntry(x: Double(index), y: fakeY))
        }

        let set = LineChartDataSet(values: entries, label: "Moving Average")
        set.setColor(UIColor.red)
        set.lineWidth = 2.5
        set.setCircleColor(UIColor.red)
        set.circleRadius = 5
        set.circleHoleRadius = 2.5
        set.fillColor = UIColor.white
        set.mode = .cubicBezier
        set.drawValuesEnabled = true
        set.valueFont = .systemFont(ofSize: 10)
        set.valueTextColor = UIColor.red

        set.axisDependency = .left

        return LineChartData(dataSet: set)
    }

    // MARK: - Actions
    @IBAction private func toFirstButtonPressed(_ sender: UIButton) {
        guard
            let firstMonth = months.first,
            let newDozes = dozes[firstMonth]
            else { return }

        currentDozes = newDozes
    }

    @IBAction private func toPreviousButtonPressed(_ sender: UIButton) {
        guard
            let newDate = currentDate.adding(.month, value: -1),
            let newDozes = dozes[newDate.monthName]
            else { return }
        currentDozes = newDozes
    }

    @IBAction private func toNextButtonPressed(_ sender: UIButton) {
        guard
            let newDate = currentDate.adding(.month, value: 1),
            let newDozes = dozes[newDate.monthName]
            else { return }
        currentDozes = newDozes
    }

    @IBAction private func toLastButtonPressed(_ sender: UIButton) {
        guard
            let firstMonth = months.last,
            let newDozes = dozes[firstMonth]
            else { return }
        currentDozes = newDozes
    }

    @IBAction private func timeScaleChanged(_ sender: UISegmentedControl) {
        guard let timeScale = TimeScale(rawValue: sender.selectedSegmentIndex) else { return }
        currentTimeScale = timeScale

        print(currentTimeScale)

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
        guard value < Double(currentDozes.count) else {
            return ""
        }
        let date = currentDozes[Int(value)].date
        return "\(date.day)\n(\(date.dayName))"
    }
}
