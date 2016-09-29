//
//  MOMExtensionTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/14/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
import Amigo

class MOMExtensionTests: XCTestCase {

    var mom: NSManagedObjectModel!

    override func setUp() {
        super.setUp()
        let name = "App"
        let bundle = NSBundle(forClass: self.dynamicType)
        let url = NSURL(string:bundle.pathForResource(name, ofType: "momd")!)!
        mom = NSManagedObjectModel(contentsOfURL: url)!

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDependencyList() {
        let list = mom.buildDependencyList()

//        list.forEach{ key, item in
//            print("\(key.name): \(item.count)")
//        }


        let cat = mom.entitiesByName["Cat"]!
        let dog = mom.entitiesByName["Dog"]!
        let people = mom.entitiesByName["People"]!

        let post = mom.entitiesByName["Post"]!
        let author = mom.entitiesByName["Author"]!

        let parent = mom.entitiesByName["Parent"]!
        let child = mom.entitiesByName["Child"]!

        let workout = mom.entitiesByName["Workout"]!
        let workoutExercise = mom.entitiesByName["WorkoutExercise"]!
        let workoutMeta = mom.entitiesByName["WorkoutMeta"]!

        //[Post: [Author], Dog: [], Author: [], People: [Cat, Dog], Cat: [], Workout: [], WorkoutExercise: [], WorkoutMeta: [Workout, WorkoutExercise], Parent: [], Child: []]
        

        // Foreign Keys
        XCTAssert(list[author]!.count == 0)
        XCTAssert(list[post]!.count == 1)

        // Foreign Keys
        XCTAssert(list[people]!.count == 2)
        XCTAssert(list[dog]!.count == 0)
        XCTAssert(list[cat]!.count == 0)

        // Many to Many + Through Model
        XCTAssert(list[workout]!.count == 0)
        XCTAssert(list[workoutExercise]!.count == 0)
        XCTAssert(list[workoutMeta]!.count == 2)

        // Many To Many
        XCTAssert(list[parent]!.count == 0)
        XCTAssert(list[child]!.count == 0)
    }

    func testTopologicalSort() {

        let list = mom.buildDependencyList()
        let sorted = mom.topologicalSort(list)

        let author = mom.entitiesByName["Author"]!
        let post = mom.entitiesByName["Post"]!

        let cat = mom.entitiesByName["Cat"]!
        let dog = mom.entitiesByName["Dog"]!
        let people = mom.entitiesByName["People"]!

        let parent = mom.entitiesByName["Parent"]!
        let child = mom.entitiesByName["Child"]!

        let workout = mom.entitiesByName["Workout"]!
        let workoutExercise = mom.entitiesByName["WorkoutExercise"]!
        let workoutMeta = mom.entitiesByName["WorkoutMeta"]!

//        sorted.forEach{
//            print($0.name)
//        }

        // [Author, Cat, Child, Dog, Parent, People, Post, Workout, WorkoutExercise, WorkoutMeta]
        let expected = [author, cat, child, dog, parent, people, post, workout, workoutExercise, workoutMeta]
        XCTAssert(sorted == expected)

    }
    
}
