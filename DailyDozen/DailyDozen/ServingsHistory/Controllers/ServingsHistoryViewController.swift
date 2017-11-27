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

    let months = ["Jan", "Feb", "Mar",
                  "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep",
                  "Oct", "Nov", "Dec"]

    var dozes: [Doze]!

    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = RealmProvider()

        let result = realm
            .getDozes()
            .sorted(byKeyPath: "date")
            .filter { $0.date.isInCurrentMonthWith(Date()) }

        dozes = Array(result)

        chartView.chartDescription?.enabled = false
        chartView.drawBarShadowEnabled = false
        chartView.highlightFullBarEnabled = false
        chartView.setScaleEnabled(false)
        chartView.dragXEnabled = true
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

        let data = CombinedChartData()
        data.barData = generateBarData()
//        data.lineData = generateLineData()

        xAxis.axisMaximum = data.xMax + 0.5
        xAxis.axisMinimum = data.xMin - 0.5

        chartView.data = data
        chartView.setVisibleXRangeMaximum(5)
        chartView.moveViewToX(Double(dozes.count))
    }

    func generateBarData() -> BarChartData {
        let barWidth = 0.9

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

        let data = BarChartData(dataSets: [set])
        data.barWidth = barWidth

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

}

extension ServingsHistoryViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = dozes[Int(value)].date
        return "\(date.day) \n (\(date.dayName))"
    }
}
