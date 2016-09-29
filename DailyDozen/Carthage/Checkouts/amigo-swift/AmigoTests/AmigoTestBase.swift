//
//  AmigoTestBase.swift
//  Amigo
//
//  Created by Adam Venturella on 7/23/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
import Amigo


class AmigoTestBase: XCTestCase {

    var amigo: Amigo!
    var engine: SQLiteEngineFactory!

    override func setUp() {
        super.setUp()
        let name = "App"
        let bundle = NSBundle(forClass: self.dynamicType)
        let url = NSURL(string:bundle.pathForResource(name, ofType: "momd")!)!
        let mom = NSManagedObjectModel(contentsOfURL: url)!

        engine = SQLiteEngineFactory(":memory:", echo: true)
        amigo = Amigo(mom, factory: engine)
        amigo.createAll()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        (amigo.config.engine as! SQLiteEngine).db.close()
    }


}
