//
//  QuickTrackerTests.swift
//  DailyDozenTests
//
//

import Foundation
import Testing
@testable import DailyDozen // module

struct DailyTrackerTests {
    
    func dateBeforeDays(_ days: Int) -> Date {
        let today = Date()
        if let pastDate = Calendar.current.date(byAdding: .day, value: days, to: today) {
            return pastDate
        }
        return today // Fallback to current date if calculation fails
    }
    
    enum MockDataScenario {
        case simple
        case complex
    }
    
    func fetchMockData(daysBeforeToday: Int, scenario: MockDataScenario = .simple) -> SqlDailyTracker {
        switch scenario {
        case .simple:
            return createSqlTracker(date: dateBeforeDays(daysBeforeToday))
        case .complex:
            return createSqlTracker(date: dateBeforeDays(daysBeforeToday))
        }
    }
    
    func createSqlTracker(date: Date) -> SqlDailyTracker {
        var tracker = SqlDailyTracker(date: date)
        
        // Add count 3 for beans
        let countBeans = SqlDataCountRecord(
            date: date,
            countType: DataCountType.dozeBeans,
            count: 3,
            streak: 1
        )
        tracker.itemsDict[.dozeBeans] = countBeans
        
        // add count 1 for greens
        let countGreens = SqlDataCountRecord(
            date: date,
            countType: DataCountType.dozeGreens,
            count: 1,
            streak: 1
        )
        tracker.itemsDict[.dozeGreens] = countGreens
        
        // add weight
        tracker.weightAM = SqlDataWeightRecord(
            date: date,
            weightType: DataWeightType.am,
            kg: 59)
        
        return tracker
    }
    
    @Test
    func testSqlDataArray() async throws {
        var data = [SqlDailyTracker]()
        print("**")
        print(createSqlTracker(date: Date()))
        print("**")
        data.append(createSqlTracker(date: Date()))
        // data.append(createSqlTracker(date: Date()))
        data.append(createSqlTracker(date: dateBeforeDays(-2)))
        data.append(createSqlTracker(date: dateBeforeDays(-5)))
        
        // print(data)
        // print(data[0].itemsDict[.dozeBeans] ?? "No Value")
        //  print(data[0].itemsDict[.dozeBeans]?.datacount_count ?? "No Value")
        //if let lastIndex = data.lastIndex(where: <#T##(SqlDailyTracker) throws -> Bool#>)
        //  print(data.count)
        
    }
    
    @Test
    func testSqlTracker() async throws {
        let date = Date()
        
        var tracker = await SqlDailyTracker(date: date)
        
        // Add count 3 for beans
        let countBeans = SqlDataCountRecord(
            date: date,
            countType: DataCountType.dozeBeans,
            count: 3,
            streak: 1
        )
        tracker.itemsDict[.dozeBeans] = countBeans
        
        // add count 1 for greens
        let countGreens = SqlDataCountRecord(
            date: date,
            countType: DataCountType.dozeGreens,
            count: 1,
            streak: 1
        )
        tracker.itemsDict[.dozeGreens] = countGreens
        
        // add weight
        tracker.weightAM = SqlDataWeightRecord(
            date: date,
            weightType: DataWeightType.am,
            kg: 59)
        
        print(tracker)
        // print(tracker.itemsDict[.dozeGreens] ?? "None")
        // print(tracker.date)
        // print(tracker.itemsDict.values)
        // print(tracker.getPid(typeKey: .dozeBeans))
        //  var item = DataCountType.dozeGreens
        
        //  print(tracker.itemsDict[item]!.datacount_count)
    }
    
}
