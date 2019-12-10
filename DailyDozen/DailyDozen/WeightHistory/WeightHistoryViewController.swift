//
//  WeightHistoryViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit
import Charts

class WeightHistoryBuilder {

    // MARK: Nested
    private struct Strings {
        static let storyboard = "WeightHistory"
    }

    // MARK: Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> WeightHistoryViewController {
        let storyboard = UIStoryboard(name: Strings.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? WeightHistoryViewController
            else { fatalError("Did not instantiate `WeightHistory` controller") }
        viewController.title = "Weight History"

        return viewController
    }
}

// MARK: -

class WeightHistoryViewController: UIViewController {

    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet private weak var controlPanel: ControlPanel! // Buttons: << < … > >>
    @IBOutlet private weak var scaleControl: UISegmentedControl! // Day|Month|Year
    @IBOutlet weak var weightEditDataButton: UIButton!
    
    // MARK: - Properties
    private var weightViewModel: WeightHistoryViewModel! // :???:
    private var currentTimeScale = TimeScale.day
    private let realm = RealmProvider()

    private var chartSettings: (year: Int, month: Int)! {
        didSet {
            lineChartView.clear()
                        
            if currentTimeScale == .day {
                controlPanel.isHidden = false
                controlPanel.superview?.isHidden = false

                var canLeft = true
                if chartSettings.month == 0, chartSettings.year == 0 {
                    canLeft = false
                }

                var canRight = true

                if chartSettings.year == weightViewModel.lastYearIndex,
                    chartSettings.month == weightViewModel.lastMonthIndex(for: weightViewModel.lastYearIndex) {
                    canRight = false
                }

                controlPanel.configure(canSwitch: (left: canLeft, right: canRight))

                let data = weightViewModel.monthData(yearIndex: chartSettings.year, monthIndex: chartSettings.month)

                controlPanel.setLabels(month: data.month, year: weightViewModel.yearName(yearIndex: chartSettings.year))

                print("year:\(controlPanel.year ?? -1) month:\(controlPanel.month ?? -1) @ .day")
                // Whole month
                let fromYear = String(format: "%04d", controlPanel.year ?? 2109)
                let fromMonth = String(format: "%02d", controlPanel.month ?? 12)
                let fromDay = String(format: "%02d", 1)
                let fromTimestampKey = "\(fromYear)\(fromMonth)\(fromDay)"
                
                let toYear = String(format: "%04d", controlPanel.year ?? 2109)
                let toMonth = String(format: "%02d", controlPanel.month ?? 12)
                let toDay = String(format: "%02d", Date.lastDayInMonth(month: controlPanel.month ?? 12, year: controlPanel.year ?? 2109))
                let toTimestampKey = "\(toYear)\(toMonth)\(toDay)"
                print("from:\(fromTimestampKey) to:\(toTimestampKey)")
                
                if let fromDate = Date(datestampKey: fromTimestampKey),
                    let toDate = Date(datestampKey: toTimestampKey) {
                    updateChart(fromDate: fromDate, toDate: toDate)
                }
                //lineChartView.configure(with: data.map, for: currentTimeScale)
                
            } else if currentTimeScale == .month {
                controlPanel.isHidden = false
                controlPanel.superview?.isHidden = false

                let canLeft = chartSettings.year != 0
                let canRight = chartSettings.year != weightViewModel.lastYearIndex
                controlPanel.configure(canSwitch: (left: canLeft, right: canRight))

                let data = weightViewModel.yearlyData(yearIndex: chartSettings.year)

                controlPanel.setLabels(year: data.year)

                print("year:\(controlPanel.year ?? -1) month:\(controlPanel.month ?? -1) @ .month")
                // Whole year
                let fromYear = String(format: "%04d", controlPanel.year ?? 2109)
                let fromMonth = String(format: "%02d", 1)
                let fromDay = String(format: "%02d", 1)
                let fromTimestampKey = "\(fromYear)\(fromMonth)\(fromDay)"
                
                let toYear = String(format: "%04d", controlPanel.year ?? 2109)
                let toMonth = String(format: "%02d", 12)
                let toDay = String(format: "%02d", 31)
                let toTimestampKey = "\(toYear)\(toMonth)\(toDay)"
                print("from:\(fromTimestampKey) to:\(toTimestampKey)")
                
                if let fromDate = Date(datestampKey: fromTimestampKey),
                    let toDate = Date(datestampKey: toTimestampKey) {
                    updateChart(fromDate: fromDate, toDate: toDate)
                }
                // :!!!: lineChartView.configure(with: data.map, for: currentTimeScale)
            } else {
                //
                controlPanel.isHidden = true
                controlPanel.superview?.isHidden = true
                
                print("year:\(controlPanel.year ?? -1) month:\(controlPanel.month ?? -1) @ .year")
                
                // Multiple years
                if let fromDate = Date(datestampKey: "20170101") {
                    updateChart(fromDate: fromDate, toDate: Date())
                }
                // :!!!: lineChartView.configure(with: weightViewModel.fullDataMap(), for: currentTimeScale)
            }
        }
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        lineChartView.xAxis.valueFormatter = self
        setViewModel()
        updateChart(fromDate: Date(), toDate: Date()) // :!!!:
    }
    
    // -------------------------
    
    // IB action, then updateChartWithData
    private func updateChartWithData(am: [ChartDataEntry], pm: [ChartDataEntry]) {

        switch currentTimeScale {
        case .day:
            break
        case .month:
            break
        case .year:
            break
        }
        
        let lineChartDataSetAM = LineChartDataSet(entries: am, label: "AM")
        lineChartDataSetAM.colors = [UIColor.yellowSunglowColor]
        lineChartDataSetAM.circleColors = [UIColor.yellowSunglowColor]
        lineChartDataSetAM.circleHoleRadius = 0.0 // Default: 4.0
        lineChartDataSetAM.circleRadius = 4.0 // Default: 8.0
        lineChartDataSetAM.drawValuesEnabled = false
        lineChartDataSetAM.lineWidth = 2.0 // Default: 1
        lineChartDataSetAM.mode = .cubicBezier

        let lineChartDataSetPM = LineChartDataSet(entries: pm, label: "PM")
        lineChartDataSetPM.colors = [UIColor.redFlamePeaColor]
        lineChartDataSetPM.circleColors = [UIColor.redFlamePeaColor]
        lineChartDataSetPM.circleHoleRadius = 0.0 // Default: 4.0
        lineChartDataSetPM.circleRadius = 4.0 // Default: 8.0
        lineChartDataSetPM.drawValuesEnabled = false
        lineChartDataSetAM.lineWidth = 2.0 // Default: 1
        lineChartDataSetPM.mode = .cubicBezier

        let lineChartData = LineChartData(dataSets: [lineChartDataSetAM, lineChartDataSetPM])
        lineChartView.data = lineChartData
        lineChartView.xAxis.drawLabelsEnabled = false
    }
    
    func updateChart(fromDate: Date, toDate: Date) {
        let fromTimeInterval = fromDate.timeIntervalSince1970
        //let toTimeInterval = toDate.timeIntervalSince1970

        // day scale = 60 seconds * 60 minutes * 24 hours
        var xScaleFactor = 60.0*60.0*24.0
        if currentTimeScale == .month {
            xScaleFactor *= 12.0
        } else if currentTimeScale == .year {
            // year scale is bi-monthly for now
            xScaleFactor *= 12.0 * 2.0
        }
        
        //var dataEntriesAM = [
        //    ChartDataEntry(x: 1.0, y: 144.3),
        //    ChartDataEntry(x: 3.0, y: 143.5),
        //]
        //dataEntriesAM.append(ChartDataEntry(x: 4.0, y: 144.5))
        var dataEntriesAM = [ChartDataEntry]()

        //let dataEntriesPM = [
        //    ChartDataEntry(x: 2.0, y: 144.9),
        //    ChartDataEntry(x: 3.0, y: 144.0),
        //    ChartDataEntry(x: 5.0, y: 144.0)
        //]
        var dataEntriesPM = [ChartDataEntry]()

        let records = realm.getDailyWeights(fromDate: fromDate, toDate: toDate)
        
        for item in records.am {
            guard let datetime = item.datetime else { continue }
            let xTimeInterval: TimeInterval = datetime.timeIntervalSince1970
            let x = (xTimeInterval - fromTimeInterval) / xScaleFactor
            var y = item.kg
            if isImperial() {
                y = item.lbs
            }
            let chartDataEntry = ChartDataEntry(x: x, y: y)
            dataEntriesAM.append(chartDataEntry)
        }
        for item in records.pm {
            guard let datetime = item.datetime else { continue }
            let xTimeInterval: TimeInterval = datetime.timeIntervalSince1970
            let x = (xTimeInterval - fromTimeInterval) / xScaleFactor
            var y = item.kg
            if isImperial() {
                y = item.lbs
            }
            let chartDataEntry = ChartDataEntry(x: x, y: y)
            dataEntriesPM.append(chartDataEntry)
        }

        updateChartWithData(am: dataEntriesAM, pm: dataEntriesPM)
    }
    
    private func isImperial() -> Bool {
        guard
            let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
            let currentUnitsType = UnitsType(rawValue: unitsTypePrefStr)
            else {
                return true
        }
        if currentUnitsType == .imperial {
            return true
        }
        return false
    }
    
    // -------------------------

    private func setViewModel() {
        let realm = RealmProvider()

        let trackers: [DailyTracker] = realm.getDailyTrackers()
        guard trackers.count > 0 else {
            controlPanel.isHidden = true
            scaleControl.isEnabled = false
            controlPanel.superview?.isHidden = true
            return
        }

        weightViewModel = WeightHistoryViewModel(trackers)
        let lastYearIndex = weightViewModel.lastYearIndex

        chartSettings = (lastYearIndex, weightViewModel.lastMonthIndex(for: lastYearIndex))
    }

    // MARK: - Actions
    
    @IBAction func editDataButtonPressed(_ sender: UIButton) {
        let viewController = WeightPagerBuilder.instantiateController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction private func toFirstButtonPressed(_ sender: UIButton) {
        chartSettings = (0, 0)
    }

    @IBAction private func toPreviousButtonPressed(_ sender: UIButton) {
        if chartSettings.month > 0 && currentTimeScale == .day {
            chartSettings.month -= 1
        } else if chartSettings.year > 0 {
            let year = chartSettings.year - 1
            let month = weightViewModel.lastMonthIndex(for: year)
            chartSettings = (year, month)
        }
    }

    @IBAction private func toNextButtonPressed(_ sender: UIButton) {
        if chartSettings.month < weightViewModel.lastMonthIndex(for: chartSettings.year) && currentTimeScale == .day {
            chartSettings.month += 1
        } else if chartSettings.year < weightViewModel.lastYearIndex {
            let year = chartSettings.year + 1
            let month = 0
            chartSettings = (year, month)
        }
    }

    @IBAction private func toLastButtonPressed(_ sender: UIButton) {
        let lastYearIndex = weightViewModel.lastYearIndex
        chartSettings = (lastYearIndex, weightViewModel.lastMonthIndex(for: lastYearIndex))
    }

    @IBAction private func timeScaleChanged(_ sender: UISegmentedControl) {
        guard let timeScale = TimeScale(rawValue: sender.selectedSegmentIndex) else { return }
        currentTimeScale = timeScale

        switch currentTimeScale {
        case .day:
            let lastYearIndex = weightViewModel.lastYearIndex
            chartSettings = (lastYearIndex, weightViewModel.lastMonthIndex(for: lastYearIndex))
        case .month:
            let lastYearIndex = weightViewModel.lastYearIndex
            chartSettings = (lastYearIndex, 0)
        case .year:
            chartSettings = (0, 0)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - IAxisValueFormatter
extension WeightHistoryViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let labels: [String]
        if currentTimeScale == .day {
            labels = weightViewModel.datesLabels(yearIndex: chartSettings.year, monthIndex: chartSettings.month)
        } else if currentTimeScale == .month {
            labels = weightViewModel.monthsLabels(yearIndex: chartSettings.year)
        } else {
            labels = weightViewModel.fullDataLabels()
        }
        let index = Int(value)
        guard index < labels.count else { return "" }
        return labels[index]
    }
}
