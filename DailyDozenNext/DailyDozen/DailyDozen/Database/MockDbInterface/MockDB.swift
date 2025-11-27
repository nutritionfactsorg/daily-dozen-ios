//
//  MockDB.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
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

func fetchMockDataId(daysBeforeToday: Int, scenario: MockDataScenario = .simple) -> SqlDailyTrackerId {
    switch scenario {
    case .simple:
        let tracker = createSqlTracker(date: dateBeforeDays(daysBeforeToday))
        return SqlDailyTrackerId(tracker: tracker)
    case .complex:
        let tracker = createSqlTracker(date: dateBeforeDays(daysBeforeToday))
        return SqlDailyTrackerId(tracker: tracker)
    }
}

//func appendMockData(date: Date) {  //TBDz: TempTesting
//    var tracker = SqlDailyTracker(date: date)
//    let trackerDict: [DataCountType: SqlDataCountRecord] = tracker.itemsDict
//    for key in trackerDict.keys {
//        let sqlDataCountRecord = trackerDict[key]!
//       
//    }
//    
//}
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
        
        print("the data is: \(data)")
    }

func fetchSQLData(date: Date = Date()) -> [SqlDailyTracker] {
  // return returnSQLDataArray(date: date)
   return mockDB
}

func appendToMockDB(_ tracker: SqlDailyTracker) {
    mockDB.append(tracker)
    print("mockDB updated: \(mockDB)") // Debug to confirm
}

func updateMockDB(with tracker: SqlDailyTracker) {
    let calendar = Calendar.current
    if let index = mockDB.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: tracker.date) }) {
        // Update existing record
        mockDB[index] = tracker
        print("mockDB updated existing record for date \(tracker.date): \(mockDB[index])")
    } else {
        // Append new record
        mockDB.append(tracker)
        print("mockDB appended new record: \(mockDB)")
    }
}

func dateBeforeDays(_ days: Int, today: Date = Date()) -> Date { // ::EDIT::
    if let pastDate = Calendar.current.date(byAdding: .day, value: days, to: today) {
        return pastDate
    }
    return today // Fallback to current date if calculation fails
}

func returnSQLDataArray(date: Date = Date()) -> [SqlDailyTracker] { // ::EDIT::
    var data: [SqlDailyTracker] = []
    
    data.append(createSqlTracker(date: date))
    data.append(createSqlTracker(date: dateBeforeDays(-2, today: date)))
    data.append(createSqlTracker(date: dateBeforeDays(-5, today: date)))
    data.append(createSqlTracker(date: dateBeforeDays(-30, today: date)))
    data.append(createSqlTracker(date: dateBeforeDays(-364, today: date)))
    // data.append(createSqlTracker(date: Date()))
    
    logit.debug("## returnSQLDataArray() count=\(data.count) ##")
    return(data)
}
//let sampleSQLArray: [SqlDailyTracker] =
//[SqlDailyTracker(
//    date: "2025-03-26 18:19:36 +0000", itemsDict: [
//        DataCountType.tweakMeal20Minutes: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 205, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakExerciseTiming: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 216, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeFlaxseeds: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 7, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakMealNegCal: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 202, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeBeverages: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 11, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakNightlySleep: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 220, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeFruitsOther: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 3, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakMealWater: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 201, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyHydrate: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 212, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeGreens: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 5, datacount_count: 1, datacount_streak: 1),
//        DataCountType.dozeSpices: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 9, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakWeightTwice: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 217, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 2, datacount_count: 0, datacount_streak: 0),
//        DataCountType.otherOmega3: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 103, datacount_count: 0, datacount_streak: 0),
//        DataCountType.otherVitaminD: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 102, datacount_count: 0, datacount_streak: 0),
//        DataCountType.otherVitaminB12: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 101, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyTimeRestrict: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 215, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakCompleteIntentions: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 218, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 1, datacount_count: 3, datacount_streak: 1),
//        DataCountType.tweakDailyGarlic: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 207, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeVegetablesCruciferous: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 4, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyDeflourDiet: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 213, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakNightlyFast: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 219, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeVegetablesOther: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 6, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyCumin: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 210, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyNutriYeast: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 209, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyBlackCumin: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 206, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyFrontLoad: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 214, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyGinger: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 208, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeWholeGrains: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 10, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakNightlyTrendelenbrug: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 221, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakMealVinegar: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 203, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyGreenTea: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 211, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakMealUndistracted: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 204, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeExercise: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 12, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeNuts: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 8, datacount_count: 0, datacount_streak: 0)
//    ],
//    weightAM: SqlDataWeightRecord(dataweight_date_psid: "2025-03-26", dataweight_ampm_pnid: 0, dataweight_kg: 59.0, dataweight_time: "11:19"),
//    weightPM: SqlDataWeightRecord(dataweight_date_psid: "2025-03-26", dataweight_ampm_pnid: 1, dataweight_kg: 0.0, dataweight_time: "11:19")
//),
// SqlDailyTracker(
//    date: "2025-03-24 18:19:36 +0000", itemsDict: [
//        DataCountType.tweakMeal20Minutes: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 205, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakExerciseTiming: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 216, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeFlaxseeds: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 7, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakMealNegCal: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 202, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeBeverages: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 11, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakNightlySleep: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 220, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeFruitsOther: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 3, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakMealWater: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 201, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyHydrate: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 212, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeGreens: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 5, datacount_count: 1, datacount_streak: 1),
//        DataCountType.dozeSpices: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 9, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakWeightTwice: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 217, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 2, datacount_count: 0, datacount_streak: 0),
//        DataCountType.otherOmega3: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 103, datacount_count: 0, datacount_streak: 0),
//        DataCountType.otherVitaminD: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 102, datacount_count: 0, datacount_streak: 0),
//        DataCountType.otherVitaminB12: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 101, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyTimeRestrict: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 215, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakCompleteIntentions: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 218, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 1, datacount_count: 3, datacount_streak: 1),
//        DataCountType.tweakDailyGarlic: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 207, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeVegetablesCruciferous: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 4, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyDeflourDiet: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 213, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakNightlyFast: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 219, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeVegetablesOther: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 6, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyCumin: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 210, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyNutriYeast: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 209, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyBlackCumin: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 206, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyFrontLoad: SqlDataCountRecord(datacount_date_psid: "2025-03-26", datacount_kind_pfnid: 214, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyGinger: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 208, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeWholeGrains: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 10, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakNightlyTrendelenbrug: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 221, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakMealVinegar: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 203, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakDailyGreenTea: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 211, datacount_count: 0, datacount_streak: 0),
//        DataCountType.tweakMealUndistracted: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 204, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeExercise: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 12, datacount_count: 0, datacount_streak: 0),
//        DataCountType.dozeNuts: SqlDataCountRecord(datacount_date_psid: "2025-03-24", datacount_kind_pfnid: 8, datacount_count: 0, datacount_streak: 0)
//    ],
//    weightAM: SqlDataWeightRecord(dataweight_date_psid: "2025-03-24", dataweight_ampm_pnid: 0, dataweight_kg: 59.0, dataweight_time: "11:19"),
//    weightPM: SqlDataWeightRecord(dataweight_date_psid: "2025-03-24", dataweight_ampm_pnid: 1, dataweight_kg: 0.0, dataweight_time: "11:19")
// )
//]

let dateA = Date(iso8601: "2025-04-15 18:19:36 +0000")!

let a: SqlDailyTracker = SqlDailyTracker(
    date: dateA, itemsDict: [
        DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-01", datacount_kind_pfnid: 1, datacount_count: 3, datacount_streak: 1)!,
        DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-01", datacount_kind_pfnid: 2, datacount_count: 0, datacount_streak: 0)!
    ], weightAM: nil, weightPM: nil
//    weightAM: SqlDataWeightRecord(dataweight_date_psid: "2025-03-26", dataweight_ampm_pnid: 0, dataweight_kg: 59.0, dataweight_time: "11:19"),
//    weightPM: SqlDataWeightRecord(dataweight_date_psid: "2025-03-26", dataweight_ampm_pnid: 1, dataweight_kg: 0.0, dataweight_time: "11:19")
)

let sampleSQLArray: [SqlDailyTracker] = [b]

let dateISOFormatter = ISO8601DateFormatter()
 
//let mockDB: [SqlDailyTracker] = returnSQLDataArray()
var mockDB: [SqlDailyTracker] =  [
    // Existing 2015 entry
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2015, month: 1, day: 1))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2015-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2015-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    // Add 2016
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2016, month: 6, day: 1))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2016-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2016-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    // Add 2017
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2017, month: 4, day: 28))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2017-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2017-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    // Add 2018
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 1))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2018-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2018-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    // Add 2019
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2019, month: 6, day: 1))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2019-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2019-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    // Add 2020
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2020, month: 6, day: 1))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2020-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2020-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    // Add 2021
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2021, month: 6, day: 1))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2021-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2021-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    // Add 2022
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2022, month: 6, day: 1))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2022-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2022-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    // Add 2023
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 1))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2023-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2023-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    // Existing 2024 entry
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2024, month: 5, day: 19))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2024-05-18", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2024-05-18", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    // Existing 2025 entries
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 14))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-04-14", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-04-14", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 9))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-09", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-09", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 12))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-12", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-12", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 29))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-29", datacount_kind_pfnid: 1, datacount_count: 3, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-29", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!,
            DataCountType.dozeBeverages: SqlDataCountRecord(datacount_date_psid: "2025-05-29", datacount_kind_pfnid: 11, datacount_count: 2, datacount_streak: 1)!
        ],
        weightAM: nil,
        weightPM: nil
    ),
    SqlDailyTracker(
        date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 1))!,
        itemsDict: [
            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-06-01", datacount_kind_pfnid: 1, datacount_count: 3, datacount_streak: 1)!,
            DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!,
            DataCountType.dozeBeverages: SqlDataCountRecord(datacount_date_psid: "2025-06-01", datacount_kind_pfnid: 11, datacount_count: 2, datacount_streak: 1)!
        ],
        weightAM: SqlDataWeightRecord(date: Date(), weightType: .am, kg: 69.5),
        weightPM: SqlDataWeightRecord(date: Date(), weightType: .pm, kg: 70.0)
    ),
    SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 2))!,
            itemsDict: [:],
            weightAM: SqlDataWeightRecord(date: Date(), weightType: .am, kg: 70.5),
            weightPM: SqlDataWeightRecord(date: Date(), weightType: .pm, kg: 71.0)
        ),
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 2))!,
            itemsDict: [:],
            weightAM: SqlDataWeightRecord(date: Date(), weightType: .am, kg: 70.3),
            weightPM: SqlDataWeightRecord(date: Date(), weightType: .pm, kg: 71.0)
        ),
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2015, month: 1, day: 2))!,
            itemsDict: [:],
            weightAM: SqlDataWeightRecord(date: Date(), weightType: .am, kg: 68.0),
            weightPM: SqlDataWeightRecord(date: Date(), weightType: .pm, kg: 68.5)
        )
]

let b: SqlDailyTracker = SqlDailyTracker(
    date: dateISOFormatter.date(from: "2025-05-12T18:19:36Z")!, itemsDict: [
        DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-12", datacount_kind_pfnid: 1, datacount_count: 3, datacount_streak: 5)!,
        DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-12", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
    ], weightAM: nil, weightPM: nil
//    weightAM: SqlDataWeightRecord(dataweight_date_psid: "2025-03-26", dataweight_ampm_pnid: 0, dataweight_kg: 59.0, dataweight_time: "11:19"),
//    weightPM: SqlDataWeightRecord(dataweight_date_psid: "2025-03-26", dataweight_ampm_pnid: 1, dataweight_kg: 0.0, dataweight_time: "11:19")
)

//TBDZZ might be useful in testing 
extension DateFormatter {
    static let sqliteDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
