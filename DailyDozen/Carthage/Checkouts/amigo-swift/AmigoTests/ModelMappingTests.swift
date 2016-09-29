//
//  ModelMappingTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/31/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import Amigo


class ModelMappingTests: XCTestCase {
    var amigo: Amigo!

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOneToMany() {
        let dog = ORMModel(Dog.self,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            OneToMany("people", using: People.self)
        )

        let people = ORMModel(People.self,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            Column("dog", type: ForeignKey(dog))
        )

        let engine = SQLiteEngineFactory(":memory:", echo: true)
        amigo = Amigo([dog, people], factory: engine)
        amigo.createAll()

        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let p1 = People()
        p1.label = "Foo"
        p1.dog = d1

        let p2 = People()
        p2.label = "Bar"
        p2.dog = d1

        session.add([d1, p1, p2])

        let results = session
            .query(People)
            .using(d1)
            .relationship("people")
            .all()

        XCTAssertEqual(results.count, 2)

    }

    func testManyToMany() {
        let parent = ORMModel(Parent.self,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            ManyToMany("children", using: Child.self)
        )

        let child = ORMModel(Child.self,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),

            // if you would like to act on the inverse
            // define it as well.
            ManyToMany("parents", using: Parent.self)
        )

        let engine = SQLiteEngineFactory(":memory:", echo: true)
        amigo = Amigo([parent, child], factory: engine)
        amigo.createAll()

        let session = amigo.session

        let p1 = Parent()
        p1.label = "Foo"

        let p2 = Parent()
        p2.label = "Foo"

        let c1 = Child()
        c1.label = "Baz"

        let c2 = Child()
        c2.label = "Qux"

        session.add([p1, p2,  c1, c2])

        // add 2 children to p1
        session.using(p1).relationship("children").add(c1, c2)

        var results = session
            .query(Child)
            .using(p1)
            .relationship("children")
            .all()

        XCTAssertEqual(results.count, 2)

        results = session
            .query(Child)
            .using(p2)
            .relationship("children")
            .all()

        XCTAssertEqual(results.count, 0)

        // add a shared parent to the children using
        // the inverse relationship to ensure it works as well
        session.using(c1).relationship("parents").add(p2)
        session.using(c2).relationship("parents").add(p2)


        results = session
            .query(Child)
            .using(p2)
            .relationship("children")
            .all()

        XCTAssertEqual(results.count, 2)

    }

    func testManyToManyThrough() {
        let workout = ORMModel(Workout.self,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            ManyToMany("exercises", using: WorkoutExercise.self, throughModel: WorkoutMeta.self)
        )

        let workoutExercise = ORMModel(WorkoutExercise.self,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let workoutMeta = ORMModel(WorkoutMeta.self,
            Column("id", type: Int.self, primaryKey: true),
            Column("duration", type: Int.self),
            Column("position", type: Int.self),
            Column("exercise", type: ForeignKey(workoutExercise)),
            Column("workout", type: ForeignKey(workout))
        )

        let engine = SQLiteEngineFactory(":memory:", echo: true)
        amigo = Amigo([workout, workoutExercise, workoutMeta], factory: engine)
        amigo.createAll()

        let session = amigo.session

        let w1 = Workout()
        w1.label = "foo"

        let e1 = WorkoutExercise()
        e1.label = "Jumping Jacks"

        let m1 = WorkoutMeta()
        m1.workout = w1
        m1.exercise = e1
        m1.duration = 60000
        m1.position = 1

        session.add([w1, e1, m1])


        let results = session
            .query(WorkoutMeta)
            .using(w1)
            .relationship("exercises")
            .orderBy("position", ascending: true)
            .all()

        XCTAssertEqual(results.count, 1)

    }
}
