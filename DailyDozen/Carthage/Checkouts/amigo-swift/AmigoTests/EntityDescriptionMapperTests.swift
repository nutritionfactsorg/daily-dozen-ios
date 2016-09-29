//
//  EntityDescriptionMapperTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/9/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
import Amigo


class EntityDescriptionMapperTests: XCTestCase {
    var mapper: EntityDescriptionMapper!
    var mom: NSManagedObjectModel!
    
    override func setUp() {
        super.setUp()

        let name = "App"
        let bundle = NSBundle(forClass: self.dynamicType)
        let url = bundle.URLForResource(name, withExtension: "momd")!

        mom = NSManagedObjectModel(contentsOfURL: url)!
        mapper = EntityDescriptionMapper()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMapper() {
        let model = mapper.map(mom.entitiesByName["Dog"]!)
        XCTAssertEqual(model.table.label, "amigotests_dog")
        XCTAssertEqual(model.type, "AmigoTests.Dog")

    }

    func testOneToManyMapping(){
        let entities = [
            mom.entitiesByName["Author"]!,
            mom.entitiesByName["Post"]!
        ]

        let models = entities.map(mapper.map)
    }

}
