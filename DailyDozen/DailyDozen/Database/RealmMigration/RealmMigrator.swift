//
//  RealmMigrator.swift
//  RealmMigration
//
//  Copyright © 2025 NutritionFacts.org. All rights reserved.
//
// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable type_body_length

import Foundation
import RealmSwift

actor RealmMigrator {
    static let shared = RealmMigrator()
    private let fm = FileManager.default

    let restRank: [Substring: Int] = [
        "dozeBeans": 0,
        "dozeBerries": 1,
        "dozeFruitsOther": 2,
        "dozeVegetablesCruciferous": 3,
        "dozeGreens": 4,
        "dozeVegetablesOther": 5,
        "dozeFlaxseeds": 6,
        "dozeNuts": 7,
        "dozeSpices": 8,
        "dozeWholeGrains": 9,
        "dozeBeverages": 10,
        "dozeExercise": 11,
        "otherVitaminB12": 12,
        "otherVitaminD": 13,
        "otherOmega3": 14,
        "tweakMealWater": 15,
        "tweakMealNegCal": 16,
        "tweakMealVinegar": 17,
        "tweakMealUndistracted": 18,
        "tweakMeal20Minutes": 19,
        "tweakDailyBlackCumin": 20,
        "tweakDailyGarlic": 21,
        "tweakDailyGinger": 22,
        "tweakDailyNutriYeast": 23,
        "tweakDailyCumin": 24,
        "tweakDailyGreenTea": 25,
        "tweakDailyHydrate": 26,
        "tweakDailyDeflourDiet": 27,
        "tweakDailyFrontLoad": 28,
        "tweakDailyTimeRestrict": 29,
        "tweakExerciseTiming": 30,
        "tweakWeightTwice": 31,
        "tweakCompleteIntentions": 32,
        "tweakNightlyFast": 33,
        "tweakNightlySleep": 34,
        "tweakNightlyTrendelenbrug": 35
    ]
    
    let ampmRank: [Substring: Int] = [
        "am": 0,
        "pm": 1
    ]
    
    let csvHeaderNames = "Date,Beans,Berries,Other Fruits,Cruciferous Vegetables,Greens,Other Vegetables,Flaxseeds,Nuts,Spices,Whole Grains,Beverages,Exercise,Vitamin B12,Vitamin D,Omega 3,Meal Water,Meal NegCal,Meal Vinegar,Meal Undistracted,Meal 20 Minutes,Daily Black Cumin,Daily Garlic,Daily Ginger,Daily NutriYeast,Daily Cumin,Daily Green Tea,Daily Hydrate,Daily Deflour Diet,Daily Front-Load,Daily Time-Restrict,Exercise Timing,Weight Twice,Complete Intentions,Nightly Fast,Nightly Sleep,Nightly Trendelenbrug,Weight AM Time,Weight AM Value,Weight PM Time,Weight PM Value\n"
    let csvHeaderGoals = "[GOALS],3,1,3,1,2,2,1,1,1,3,5,1,1,1,1,3,3,3,3,3,1,1,1,1,2,3,1,1,1,1,1,2,3,1,1,1,[am],[kg],[pm],[kg]\n"
    
    //let typeCount = 36        // typeOrder.count
    //let pidDateEndIdx = 8     // keep "YYYYMMDD"
    //let pidValueStartIdx = 9  // skip "YYYYMMDD." keep value.
    
    // Function to sort and merge into CSV
    // Returns `true` if successful
    func generateCSV() async -> URL? {
        let realmURL = URL.inDatabase(filename: "NutritionFacts.realm")
        
        let datetime = Date().ISO8601Format()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ":", with: "")
        //let csvCountURL = realmURL
        //    .deletingPathExtension()
        //    .appendingPathExtension("1_count_\(datetime).csv")
        //let csvWeightURL = realmURL
        //    .deletingPathExtension()
        //    .appendingPathExtension("2_weight_\(datetime).csv")
        let csvMigrateURL = realmURL
            .deletingPathExtension()
            .appendingPathExtension("backup_\(datetime).csv")
        
        guard let realm = openUpgradedRealm(fromURL: realmURL)
        else {
            print("•REALM_MIGRATION•FAIL• realm db open failed.")
            return nil
        }
        
        let countRecords: Results<DataCountRecord> = realm.objects(DataCountRecord.self)
        var dataCountArray = [DataCountRecord]()
        for r in countRecords { // size: countRecords.count
            dataCountArray.append(r)
        }
        let weightRecords: Results<DataWeightRecord> = realm.objects(DataWeightRecord.self)
        var dataWeightArray = [DataWeightRecord]()
        for r in weightRecords { // size: weightRecords.count
            dataWeightArray.append(r)
        }
        
        print("•INFO•DB• RealmMigrator CSV generation started \(Date().datestampyyyyMMddHHmmssSSS)")
        let clock = ContinuousClock()
        let benchmarkStart = clock.now
        
        // Step 1: Sort dataCountArray by date (primary), then rest rank (secondary)
        dataCountArray.sort { a, b in
            let dateA = a.pid.prefix(8)
            let dateB = b.pid.prefix(8)
            if dateA != dateB {
                return dateA < dateB
            }
            let restA = a.pid.dropFirst(9)
            let restB = b.pid.dropFirst(9)
            let rankA = restRank[restA] ?? Int.max
            let rankB = restRank[restB] ?? Int.max
            return rankA < rankB
        }
        
        // Step 2: Sort dataWeightArray by date (primary), then am/pm rank (secondary)
        dataWeightArray.sort { a, b in
            let dateA = a.pid.prefix(8)
            let dateB = b.pid.prefix(8)
            if dateA != dateB {
                return dateA < dateB
            }
            let restA = a.pid.dropFirst(9)
            let restB = b.pid.dropFirst(9)
            let rankA = ampmRank[restA] ?? Int.max
            let rankB = ampmRank[restB] ?? Int.max
            return rankA < rankB
        }
        
        // Step 3: Create or overwrite the CSV export file
        let fileHandle: FileHandle
        do {
            if fm.fileExists(atPath: csvMigrateURL.path(percentEncoded: false)) {
                try fm.removeItem(at: csvMigrateURL)
                print("•REALM_MIGRATION•PASS• prior CSV migration file removed OK.")
            }
            guard fm.createFile(atPath: csvMigrateURL.path, contents: nil)
            else {
                print("""
                •REALM_MIGRATION•FAIL• could not create the CSV migration file.
                    File: \(csvMigrateURL.path(percentEncoded: false))
                """)
                return nil
            }
            fileHandle = try FileHandle(forWritingTo: csvMigrateURL)
            print("•REALM_MIGRATION•PASS• CSV migration FileHandle opened OK.")
            try fileHandle.write(contentsOf: Data(csvHeaderNames.utf8))
            try fileHandle.write(contentsOf: Data(csvHeaderGoals.utf8))
            print("•REALM_MIGRATION•PASS• CSV migration file header written OK.")
        } catch {
            print("""
            •REALM_MIGRATION•FAIL• could not setup the CSV migration file.
                File: \(csvMigrateURL.path(percentEncoded: false))
               Error: \(error)
            """)
            return nil
        }
        
        // Step 4: Merge with two-pointer approach, grouping by date
        var countIndex = 0
        var weightIndex = 0
        
        while countIndex < dataCountArray.count || weightIndex < dataWeightArray.count {
            // Determine the next date from the fronts of remaining elements
            var currentDate: Substring?
            if countIndex < dataCountArray.count && weightIndex < dataWeightArray.count {
                let dateC = dataCountArray[countIndex].pid.prefix(8)
                let dateW = dataWeightArray[weightIndex].pid.prefix(8)
                currentDate = min(dateC, dateW)
            } else if countIndex < dataCountArray.count {
                currentDate = dataCountArray[countIndex].pid.prefix(8)
            } else if weightIndex < dataWeightArray.count {
                currentDate = dataWeightArray[weightIndex].pid.prefix(8)
            }
            guard let date = currentDate else { break }
            
            // Initialize row components
            var countValues = [String](repeating: "0", count: 36)
            //var countValues = [Substring](repeating: "0", count: 36)
            var amTime = ""
            var amValue = ""
            var pmTime = ""
            var pmValue = ""
            
            // Process all counts for this date
            while countIndex < dataCountArray.count && dataCountArray[countIndex].pid.prefix(8) == date {
                let record = dataCountArray[countIndex]
                let rest = record.pid.dropFirst(9)
                if let colIndex = restRank[rest] {
                    countValues[colIndex] = "\(record.count)"  // Use count; adjust to streak if needed
                }
                countIndex += 1
            }
            
            // Process all weights for this date (at most 2)
            while weightIndex < dataWeightArray.count && dataWeightArray[weightIndex].pid.prefix(8) == date {
                let record = dataWeightArray[weightIndex]
                let ampm = record.pid.dropFirst(9)
                
                //if let rank = ampmRank[ampm] {
                //    if rank == 0 {
                //        amTime = record.time
                //        amValue = "\(record.kg)"
                //    } else if rank == 1 {
                //        pmTime = record.time
                //        pmValue = "\(record.kg)"
                //    }
                //}
                
                if ampm == "am" {
                    amTime = record.time
                    amValue = "\(record.kg)"
                } else if ampm == "pm" {
                    pmTime = record.time
                    pmValue = "\(record.kg)"
                }
                weightIndex += 1
                
                //if let rank = ampmRank[ampm] {
                //    switch rank {
                //    case 0:  // "am"
                //        amTime = record.time
                //        amValue = "\(record.kg)"
                //    case 1:  // "pm"
                //        pmTime = record.time
                //        pmValue = "\(record.kg)"
                //    default:
                //        break  // Unexpected value — ignore (or log in debug)
                //    }
                //}
            }
            
            // Build and write the row
            //let csvRow = "\(date)," + countValues.joined(separator: ",") + ",\(amTime),\(amValue),\(pmTime),\(pmValue)\n"
            
            // String Builder Pattern
            var rowParts = [String]()
            rowParts.append(String(date))            // One allocation per date
            rowParts.append(contentsOf: countValues) // Already Strings
            rowParts.append(amTime)
            rowParts.append(amValue)
            rowParts.append(pmTime)
            rowParts.append(pmValue)
            
            let csvRow = rowParts.joined(separator: ",") + "\n"
            
            do {
                try fileHandle.seekToEnd()
                try fileHandle.write(contentsOf: Data(csvRow.utf8))
            } catch {
                return nil
            }
        }
                
        // Step 5: Close the file
        realm.invalidate()
        do {
            try fileHandle.close()
        } catch {
            print("""
            •REALM_MIGRATION•FAIL• could not close the CSV migration file.
                File: \(csvMigrateURL.path(percentEncoded: false))
                Error: \(error)
            """)
            return nil
        }
        
        // Step 6: Place CSV copy in documents
        let csvCopyURL = URL
            .documentsDirectory
            .appendingPathComponent(csvMigrateURL.lastPathComponent)
        do {
            try fm.copyItem(at: csvMigrateURL, to: csvCopyURL)
            print("•REALM_MIGRATION•PASS• docs copy made of original CSV.")
        } catch {
            print("""
            •REALM_MIGRATION•FAIL• unable to create docs copy of original CSV.
                From: \(csvMigrateURL.path(percentEncoded: false))
                  To: \(csvCopyURL.path(percentEncoded: false))
            """)
            return nil
        }

        let benchmarkDuration = clock.now - benchmarkStart
        print("•INFO•DB• RealmMigrator CSV Generation Finished at \(Date().datestampyyyyMMddHHmmssSSS)")
        print("Total duration: \(benchmarkDuration.formatted(.units(allowed: [.seconds, .milliseconds, .microseconds])))")

        return csvMigrateURL
    }
    
    private func openUpgradedRealm(fromURL: URL) -> Realm? {
        let fm = FileManager.default
        
        // Step 0: Check if a Realm file exists to be upgraded
        guard fm.fileExists(atPath: fromURL.path(percentEncoded: false))
        else {
            print("""
            •REALM_MIGRATION• no realm file available to upgrade.
                File: \(fromURL.path(percentEncoded: false))
            """)
            return nil
        }
        
        // Step 1: Make copy of the original Realm file for upgrading
        let upgradedURL = fromURL
            .deletingPathExtension()
            .appendingPathExtension("upgraded.realm")
        
        // remove any prior "…upgraded.realm"
        if fm.fileExists(atPath: upgradedURL.path(percentEncoded: false)) {
            do {
                try fm.removeItem(at: upgradedURL)
                print("•REALM_MIGRATION•PASS• prior upgraded file removed OK.")
            } catch {
                print("""
                •REALM_MIGRATION•FAIL• could not remove the prior existing upgraded file.
                    File: \(upgradedURL.path(percentEncoded: false))
                    Error: \(error)
                """)
                return nil
            }
        } else {
            print("•REALM_MIGRATION•PASS• no prior upgraded file.")
        }
        
        // make the upgrading copy
        do {
            try fm.copyItem(at: fromURL, to: upgradedURL)
            print("•REALM_MIGRATION•PASS• copy made of original DB.")
        } catch {
            print("""
            •REALM_MIGRATION•FAIL• unable to create copy of original DB.
                From: \(fromURL.path(percentEncoded: false))
                  To: \(upgradedURL.path(percentEncoded: false))
            """)
            return nil
        }
        
        // Step 2: Upgrade Realm database in isolated autoreleasepool
        return autoreleasepool {
            var config = Realm.Configuration()
            config.fileURL = upgradedURL
            config.readOnly = false
            
            // Upgrade happens here
            guard let realm: Realm = try? Realm(configuration: config)
            else {
                print("•REALM_MIGRATION•FAIL• unable to open upgraded DB. \(config)")
                return nil
            }
            return realm
        }
    }
    
}
