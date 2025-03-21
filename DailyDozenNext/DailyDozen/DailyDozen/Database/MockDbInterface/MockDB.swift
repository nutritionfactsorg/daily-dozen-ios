//
//  MockDB.swift
//  DailyDozen
//
//  Created by mc on 3/13/25.
//
import SwiftUI

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
    
    func testSqlDataArray() async throws {
        var data = [SqlDailyTracker]()
        
        data.append(createSqlTracker(date: Date()))
        data.append(createSqlTracker(date: dateBeforeDays(-2)))
        data.append(createSqlTracker(date: dateBeforeDays(-5)))
       // data.append(createSqlTracker(date: Date()))
        
        print(data)
    }

func returnSQLDataArray() -> [SqlDailyTracker] {
    var data = [SqlDailyTracker]()
    
    data.append(createSqlTracker(date: Date()))
    data.append(createSqlTracker(date: dateBeforeDays(-2)))
    data.append(createSqlTracker(date: dateBeforeDays(-5)))
   // data.append(createSqlTracker(date: Date()))
    
    return(data)
}
