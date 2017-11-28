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

    // MARK: - Outlets
    @IBOutlet private weak var chartView: CombinedChartView!
    @IBOutlet private weak var monthLabel: UILabel! {
        didSet {
            monthLabel.text = Date().monthName
        }
    }

    // MARK: - Properties
    private var dozes = [String: [Doze]]()
    private var currentDozes = [Doze]()
    private var currentDate = Date() {
        didSet {
            monthLabel.text = currentDate.monthName
        }
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = RealmProvider()

        let result = realm
            .getDozes()
            .sorted(byKeyPath: "date")

        result.forEach { doze in
            if dozes[doze.date.monthName] == nil {
                dozes.updateValue([], forKey: doze.date.monthName)
            }
            dozes[doze.date.monthName]?.append(doze)
        }

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

        currentDate = Date().adding(.month, value: -1) ?? Date()
        guard let newDozes = dozes[currentDate.monthName] else { return }
        currentDozes = newDozes
        setChartData()
    }

    func setChartData() {
        let data = CombinedChartData()
        data.barData = generateBarData(for: currentDozes)
//        data.lineData = generateLineData()
        print(data.xMax, data.xMin)

        chartView.xAxis.axisMaximum = data.xMax + 0.5
        chartView.xAxis.axisMinimum = data.xMin - 0.5

        chartView.data = data

//        chartView.setVisibleXRangeMaximum(7)
//        chartView.moveViewToX(Double(currentDozes.count))

        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
    }

    // MARK: - Methods
    func generateBarData(for dozes: [Doze]) -> BarChartData {

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

    func generateLineData() -> LineChartData {
        let entries = (0..<12).map { (i) -> ChartDataEntry in
            return ChartDataEntry(x: Double(i) + 0.5, y: Double(arc4random_uniform(15) + 5))
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
    @IBAction private func nextButtonPressed(_ sender: UIButton) {
        guard
            let newDate = currentDate.adding(.month, value: 1),
            let newDozes = dozes[newDate.monthName]
            else { return }
        chartView.clear()
        currentDozes.removeAll()
        currentDozes = newDozes
        currentDate = newDate
        setChartData()
    }

    @IBAction private func previousButtonPressed(_ sender: UIButton) {
        guard
            let newDate = currentDate.adding(.month, value: -1),
            let newDozes = dozes[newDate.monthName]
            else { return }
        chartView.clear()
        currentDozes.removeAll()
        currentDozes = newDozes
        currentDate = newDate
        setChartData()
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
