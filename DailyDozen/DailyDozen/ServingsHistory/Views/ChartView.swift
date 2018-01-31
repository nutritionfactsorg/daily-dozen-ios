//
//  ChartView.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 07.12.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import Charts

class ChartView: CombinedChartView {

    override func awakeFromNib() {
        super.awakeFromNib()

        chartDescription?.enabled = false
        drawBarShadowEnabled = false
        highlightFullBarEnabled = false
        setScaleEnabled(false)
        dragYEnabled = false

        drawOrder = [DrawOrder.bar.rawValue,
                               DrawOrder.line.rawValue]

        legend.wordWrapEnabled = true
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.drawInside = false

        rightAxis.axisMinimum = 0
        rightAxis.labelTextColor = UIColor.darkBlueColor
        rightAxis.labelFont = UIFont.helevetica.withSize(12)

        leftAxis.axisMinimum = 0
        leftAxis.labelTextColor = UIColor.darkBlueColor
        leftAxis.labelFont = UIFont.helevetica.withSize(12)

        xAxis.labelPosition = .bothSided
        xAxis.granularity = 1
        xAxis.labelTextColor = .darkBlueColor
        xAxis.labelFont = UIFont.helevetica.withSize(12)
    }

    func configure(with map: [Int], for scale: TimeScale) {
        let data = CombinedChartData()
        if scale == .day {
            data.barData = generateBarData(for: map)
        } else {
            let lineMap = map.map { Double($0) }
            data.lineData = generateLineData(for: lineMap)
        }

        xAxis.axisMaximum = data.xMax + 0.5
        xAxis.axisMinimum = data.xMin - 0.5

        self.data = data

        setVisibleXRange(minXRange: 3, maxXRange: 7)
        moveViewToX(Double(map.count))

        self.data?.notifyDataChanged()
        notifyDataSetChanged()
        setNeedsDisplay()
    }

    private func generateBarData(for map: [Int]) -> BarChartData {

        var entries = [BarChartDataEntry]()

        for (index, value) in map.enumerated() {
            entries.append(BarChartDataEntry(x: Double(index), y: Double(value)))
        }

        let set = BarChartDataSet(values: entries, label: "Servings")
        set.setColor(UIColor.greenColor)
        set.valueTextColor = UIColor.greenColor
        set.valueFont = UIFont.helveticaBold.withSize(12)
        set.axisDependency = .left

        let data = BarChartData(dataSet: set)

        return data
    }

    private func generateLineData(for map: [Double]) -> LineChartData {

        var entries = [ChartDataEntry]()

        for (index, value) in map.enumerated() {
            entries.append(ChartDataEntry(x: Double(index), y: value))
        }

        let set = LineChartDataSet(values: entries, label: "Servings")
        set.setColor(UIColor.greenColor)
        set.lineWidth = 2.5
        set.setCircleColor(UIColor.greenColor)
        set.circleRadius = 5
        set.circleHoleRadius = 2.5
        set.fillColor = UIColor.white
        set.mode = .cubicBezier
        set.drawValuesEnabled = true
        set.valueFont = UIFont.helveticaBold.withSize(12)
        set.valueTextColor = UIColor.greenColor
        set.axisDependency = .left

        return LineChartData(dataSet: set)
    }
}
