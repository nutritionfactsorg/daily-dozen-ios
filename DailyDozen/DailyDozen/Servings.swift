//
//  Servings.swift
//  DailyDozen
//
//  Created by Will Webb on 9/29/16.
//  Copyright © 2016 NutritionFacts.org. All rights reserved.
//

import Amigo

class Servings: AmigoModel {
    static let ServingNames = ["Beans", "Berries", "Other Fruits", "Cruciferous Vegetables", "Greens", "Other Vegetables", "Flaxseeds", "Nuts", "Spices", "Whole Grains", "Beverages", "Exercise"]
    static let ServingImages = ["ic_beans", "ic_berries", "ic_other_fruits", "ic_cruciferous", "ic_greens", "ic_other_veg", "ic_flax", "ic_nuts", "ic_spices", "ic_whole_grains", "ic_beverages", "ic_exercise"]
    static let ServingSizes = [3, 1, 3, 1, 2, 2, 1, 1, 1, 3, 5, 1]
    
    dynamic var day = Servings.getDatabaseDate(NSDate())
    dynamic var beans = 0
    dynamic var berries = 0
    dynamic var other_fruits = 0
    dynamic var cruciferous_vegetables = 0
    dynamic var greens = 0
    dynamic var other_vegetables = 0
    dynamic var flaxseeds = 0
    dynamic var nuts = 0
    dynamic var spices = 0
    dynamic var whole_grains = 0
    dynamic var beverages = 0
    dynamic var exercise = 0
    var indexedServings = []
    
    override init() {
        super.init()
        
        indexedServings = [beans, berries, other_fruits, cruciferous_vegetables, greens, other_vegetables, flaxseeds, nuts, spices, whole_grains, beverages, exercise]
    }
    
    func getServingByIndex(index: Int) -> Int {
        return indexedServings[index] as! Int
    }
    
    func addServingByIndex(index: Int, serving: Int) -> Int {
        switch index {
        case 0:
            beans += serving
        case 1:
            berries += serving
        case 2:
            other_fruits += serving
        case 3:
            cruciferous_vegetables += serving
        case 4:
            greens += serving
        case 5:
            other_vegetables += serving
        case 6:
            flaxseeds += serving
        case 7:
            nuts += serving
        case 8:
            spices += serving
        case 9:
            whole_grains += serving
        case 10:
            beverages += serving
        case 11:
            exercise += serving
        default:
            return -1
        }
        
        let session = amigo.session
        session.begin()
        session.add(self, upsert: true)
        session.commit()
        
        return getServingByIndex(index)
    }
    
    static func getDatabaseDate(date: NSDate) -> NSDate? {
        return NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.dateFromComponents(NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.components([.Day , .Month, .Year ], fromDate: date))
    }
}

let amigo: Amigo = {
    let documentsFolder: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let databasePath = documentsFolder.stringByAppendingPathComponent("DailyDozen.sqlite")
    let servings = ORMModel(Servings.self, DateTimeField("day", primaryKey: true), IntegerField("beans"), IntegerField("berries"), IntegerField("other_fruits"), IntegerField("cruciferous_vegetables"),
                            IntegerField("greens"), IntegerField("other_vegetables"), IntegerField("flaxseeds"), IntegerField("nuts"), IntegerField("spices"), IntegerField("whole_grains"),
                            IntegerField("beverages"), IntegerField("exercise"))
    
    let engine = SQLiteEngineFactory(databasePath, echo: false)
    let amigo = Amigo([servings], factory: engine)
    amigo.createAll()
    
    return amigo
}()