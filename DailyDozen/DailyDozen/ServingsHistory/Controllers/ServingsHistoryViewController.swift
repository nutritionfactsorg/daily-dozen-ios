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
    private var report: Report!

    private var pageCodes: (year: Int, month: Int)! {
        didSet {
            chartView.clear()

            toFirstButton.isEnabled = pageCodes.month > 0
            toPreviousButton.isEnabled = pageCodes.month > 0
            toNextButton.isEnabled = pageCodes.month < report.data.last!.months.count - 1
            toLastButton.isEnabled = pageCodes.month < report.data.last!.months.count - 1

            monthLabel.text = report.data[pageCodes.year].months[pageCodes.month].month
            setChartData()
        }
    }
    private var currentTimeScale = TimeScale.day

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

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

    private func setChartData() {
        let data = CombinedChartData()
        let map = report.data[pageCodes.year].months[pageCodes.month].daily.map { $0.statesCount }
        if currentTimeScale == .day {
            data.barData = generateBarData(for: map)
            data.lineData = generateLineData(for: map)
        } else {
//            data.lineData = generateLineData(from: currentDozesMap)
        }

        chartView.xAxis.axisMaximum = data.xMax + 0.5
        chartView.xAxis.axisMinimum = data.xMin - 0.5

        chartView.data = data

        chartView.setVisibleXRange(minXRange: 3, maxXRange: 7)
        chartView.moveViewToX(Double(map.count))

        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
        chartView.setNeedsDisplay()
    }

    private func generateBarData(for map: [Int]) -> BarChartData {

        var entries = [BarChartDataEntry]()

        for (index, value) in map.enumerated() {
            entries.append(BarChartDataEntry(x: Double(index), y: Double(value)))
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

    private func generateLineData(for map: [Int]) -> LineChartData {

        var entries = [ChartDataEntry]()

        for (index, value) in map.enumerated() {
            let fakeY = Double(value) / 3.0
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
