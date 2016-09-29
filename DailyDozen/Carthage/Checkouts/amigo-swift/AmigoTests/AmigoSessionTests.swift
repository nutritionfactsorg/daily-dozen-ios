//
//  AmigoSessionTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/23/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import FMDB
@testable import Amigo


class AmigoSessionTests: AmigoTestBase {

    func testNestedTransactions(){
        let done  = expectationWithDescription("done")
        let queue = dispatch_queue_create("tests.queue", nil)

        amigo.createAll()

        let dog = amigo.query(Dog).get(1)
        let session = amigo.session

        XCTAssertNil(dog)

        let o1 = Dog()
        o1.label = "lucy"

        session.add(o1)

        dispatch_async(queue){
            let session = self.amigo.session

            var results = self.amigo.query(Dog).all()

            XCTAssert(results.count == 1)

            let o2 = Dog()
            o2.label = "ollie"

            session.add(o2)

            results = self.amigo.query(Dog).all()

            XCTAssert(results.count == 2)

            session.rollback()
            results = self.amigo.query(Dog).all()

            XCTAssert(results.count == 1)

            done.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testUpsert(){

        let session = amigo.session
        let o1 = Dog()
        o1.label = "lucy"


        session.add(o1, upsert: true)

        XCTAssert(o1.id != nil)

        o1.label = "ollie"

        session.add(o1, upsert: true)

        if let result = session.query(Dog).all().first{
            XCTAssert(result.label == "ollie")
        }

    }

    func testUpsertWithForeignKey(){

        let session = amigo.session

        let d1 = Dog()
        d1.label = "lucy"

        let p1 = People()
        p1.label = "Foo"
        p1.dog = d1

        session.add(p1, upsert: true)

        if let result = session.query(People).selectRelated("dog").all().first{
            XCTAssert(result.id == 1)
            XCTAssert(result.label == "Foo")
            XCTAssert(result.dog.label == "lucy")
            XCTAssert(result.dog.id == 1)
        }

        d1.label = "ollie"
        session.add(d1, upsert: true)

        if let result = session.query(People).selectRelated("dog").all().first{
            XCTAssert(result.id == 1)
            XCTAssert(result.label == "Foo")
            XCTAssert(result.dog.label == "ollie")
            XCTAssert(result.dog.id == 1)
        }
    }

    func testInsert(){

        var candidate = amigo.query(Dog).get(1)
        XCTAssertNil(candidate)

        let session = amigo.session
        let o1 = Dog()
        o1.label = "lucy"

        XCTAssertNil(o1.id)

        session.add(o1)

        XCTAssertNotNil(o1.id)

        candidate = amigo.query(Dog).get(1)
        XCTAssertNotNil(candidate)
    }

    func testDelete(){
        let session = amigo.session
        let o1 = Dog()

        o1.label = "lucy"

        session.add(o1)

        var candidate = session.query(Dog).get(1)
        XCTAssertNotNil(candidate)

        session.delete(o1)

        candidate = session.query(Dog).get(1)
        XCTAssertNil(candidate)
    }

    func testDeleteCached(){
        let session = amigo.session
        let o1 = Dog()
        o1.label = "lucy"

        let o2 = Dog()
        o2.label = "ollie"

        let o3 = Dog()
        o3.label = "gato"

        session.add([o1, o2, o3])

        var candidates = session.query(Dog).all()
        XCTAssert(candidates.count == 3)

        session.delete([o1, o2, o3])

        candidates = session.query(Dog).all()
        XCTAssert(candidates.count == 0)
    }

    func testDeleteNoPrimaryKey(){
        let session = amigo.session
        let o1 = Dog()

        o1.label = "lucy"

        session.delete(o1)
    }

    func testUpdate(){
        var candidate = amigo.query(Dog).get(1)
        XCTAssertNil(candidate)

        let session = amigo.session
        let o1 = Dog()
        o1.label = "lucy"

        XCTAssertNil(o1.id)

        session.add(o1)

        o1.label = "ollie"

        session.add(o1)

        candidate = amigo.query(Dog).get(1)
        XCTAssertEqual(candidate!.label, "ollie")
    }

    func testUpdateCached(){

        let session = amigo.session
        let o1 = Dog()
        o1.label = "lucy"
        session.add(o1)

        o1.label = "ollie"
        session.add(o1)

        o1.label = "gato"
        session.add(o1)

        let candidate = amigo.query(Dog).get(1)!
        XCTAssertEqual(candidate.label, "gato")
    }

    func testUpdateFromNoForeignKey(){

        let session = amigo.session

        let p1 = People()
        p1.label = "foo"

        let d1 = Dog()
        d1.label = "lucy"

        session.add(p1)

        XCTAssertEqual(p1.id, 1)
        XCTAssertNil(d1.id)

        p1.dog = d1

        session.add(p1)

        XCTAssertNotNil(d1.id)
        XCTAssertEqual(d1.id, 1)

    }

    func testUpdateWithNewForeignKey(){

        let session = amigo.session

        let p1 = People()
        p1.label = "foo"

        let d1 = Dog()
        d1.label = "lucy"

        let d2 = Dog()
        d2.label = "ollie"

        p1.dog = d1

        session.add(p1)
        session.add(d1)
        session.add(d2)

        var result = session
            .query(People)
            .selectRelated("dog")
            .get(1)!

        XCTAssertNotNil(result.dog)
        XCTAssertEqual(result.dog.id, d1.id)

        result.dog = d2
        session.add(result)

        result = session
            .query(People)
            .selectRelated("dog")
            .get(1)!

        XCTAssertNotNil(result.dog)
        XCTAssertEqual(result.dog.id, d2.id)
    }

    func testBatchUpsert(){

        let session = amigo.session

        let objs = (0..<10).map{ _ -> Dog in
            let d = Dog()
            d.label = "lucy's"
            return d
        }

        session.batch{ batch in
            objs.forEach{
                batch.add($0, upsert: true)
            }
        }

        // batches don't update anying on the models, so we
        // need to re-query to get our primary keys.
        // or doing an upsert will be an insert as the 
        // primaryKey will be NULL
        let results = session.query(Dog).all().flatMap{$0}
        XCTAssert(results.count == 10)

        results.forEach{
            $0.label = "ollie's"
        }

        session.batch{ batch in
            results.forEach{
                batch.add($0, upsert: true)
            }
        }

        XCTAssert(session.query(Dog).filter("label = \"ollie's\"").all().count == 10)
        XCTAssert(session.query(Dog).filter("label = \"lucy's\"").all().count == 0)
    }

    func testBatchInsert(){

        let session = amigo.session

        let objs = (0..<10).map{ _ -> Dog in
            let d = Dog()
            d.label = "lucy's"
            return d
        }

        session.batch{ batch in
            objs.forEach{
                batch.add($0)
            }
        }

        XCTAssert(session.query(Dog).all().count == 10)
    }

    func testBatchUpdate(){

        let session = amigo.session

        let objs = (0..<10).map{ _ -> Dog in
            let d = Dog()
            d.label = "lucy's"
            return d
        }

        session.batch{ batch in
            objs.forEach{
                batch.add($0)
            }
        }

        let results = session.query(Dog).all().flatMap{$0}

        results.forEach{
            $0.label = "ollie's"
        }

        session.batch{ batch in
            results.forEach{
                batch.add($0)
            }
        }

    }

    func testBatchInsertUpdate(){

        let session = amigo.session

        let objs = (0..<10).map{ _ -> Dog in
            let d = Dog()
            d.label = "lucy's"
            return d
        }

        session.batch{ batch in
            objs.forEach{
                batch.add($0)
            }
        }

        let results = session.query(Dog).all().flatMap{$0}

        results.forEach{
            $0.label = "ollie's"
        }

        let new = (0..<10).map{ _ -> Dog in
            let d = Dog()
            d.label = "lucy's"
            return d
        }


        session.batch{ batch in
            results.forEach(batch.add)
            new.forEach(batch.add)
        }


        let total = session.query(Dog).all()
        let ollie = session.query(Dog)
            .filter("label = \"ollie's\"")
            .all()
        let lucy = session.query(Dog)
            .filter("label = \"lucy's\"")
            .all()

        XCTAssert(total.count == 20)
        XCTAssert(ollie.count == 10)
        XCTAssert(lucy.count == 10)
    }

    func testBatchDelete(){
        let session = amigo.session

        let objs = (0..<10).map{ _ -> Dog in
            let d = Dog()
            d.label = "lucy's"
            return d
        }

        session.batch{ batch in
            objs.forEach{
                batch.add($0)
            }
        }

        let results = session.query(Dog).all().flatMap{$0}
        XCTAssert(results.count == objs.count)


        session.batch{ batch in
            results.forEach(batch.delete)
        }

        XCTAssert(session.query(Dog).all().count == 0)
    }

    func testBatchDeleteThroughModels(){

        let session = amigo.session

        let w1 = Workout()
        w1.label = "foo"

        let w2 = Workout()
        w2.label = "bar"

        let e1 = WorkoutExercise()
        e1.label = "Jumping Jacks"

        let e2 = WorkoutExercise()
        e2.label = "Push-Ups"

        let m1 = WorkoutMeta()
        m1.workout = w1
        m1.exercise = e1
        m1.duration = 60000
        m1.position = 1

        let m2 = WorkoutMeta()
        m2.workout = w1
        m2.exercise = e2
        m2.duration = 15
        m2.position = 2

        // intentionally add a new WorkoutMeta with
        // a different parent workout
        // so the id of the final WorkoutMeta will
        // not be consecutive
        let m3 = WorkoutMeta()
        m3.workout = w2
        m3.exercise = e2
        m3.duration = 60
        m3.position = 1

        let m4 = WorkoutMeta()
        m4.workout = w1
        m4.exercise = e2
        m4.duration = 25
        m4.position = 3

        session.add(w1)
        session.add(w2)
        session.add(e1)
        session.add(e2)
        session.add(m1)
        session.add(m2)
        session.add(m3)
        session.add(m4)

        XCTAssert(session.query(WorkoutMeta).all().count == 4)

        let sql = "SELECT COUNT(*) FROM amigotests_workout_amigotests_workoutexercise"

        amigo.execute(sql, params: nil){ (results: FMResultSet) -> () in
            results.next()
            let count = Int(results.intForColumnIndex(0))
            XCTAssert(count == 4)
            results.close()
        }

        session.batch{ batch in
            batch.delete(m1)
            batch.delete(m2)
            batch.delete(m3)
            batch.delete(m4)
        }

        XCTAssert(session.query(WorkoutMeta).all().count == 0)

        amigo.execute(sql, params: nil){ (results: FMResultSet) -> () in
            results.next()
            let count = Int(results.intForColumnIndex(0))
            XCTAssert(count == 0)
            results.close()
        }
    }

    func testBatchInsertThroughModelsNoPrimaryKey(){

        let session = amigo.session

        let w1 = Workout()
        w1.label = "foo"

        let w2 = Workout()
        w2.label = "bar"

        let e1 = WorkoutExercise()
        e1.label = "Jumping Jacks"

        let e2 = WorkoutExercise()
        e2.label = "Push-Ups"

        let m1 = WorkoutMeta()
        m1.workout = w1
        m1.exercise = e1
        m1.duration = 60000
        m1.position = 1

        let m2 = WorkoutMeta()
        m2.workout = w1
        m2.exercise = e2
        m2.duration = 15
        m2.position = 2

        // intentionally add a new WorkoutMeta with
        // a different parent workout
        // so the id of the final WorkoutMeta will
        // not be consecutive
        let m3 = WorkoutMeta()
        m3.workout = w2
        m3.exercise = e2
        m3.duration = 60
        m3.position = 1

        let m4 = WorkoutMeta()
        m4.workout = w1
        m4.exercise = e2
        m4.duration = 25
        m4.position = 3

        print(w1.id ?? 0)
        session.batch{ batch in
            batch.add([m1, m2, m3, m4])
        }

        XCTAssert(session.query(WorkoutMeta).all().count == 4)

        let sql = "SELECT COUNT(*) FROM amigotests_workout_amigotests_workoutexercise"

        amigo.execute(sql, params: nil){ (results: FMResultSet) -> () in
            results.next()
            let count = Int(results.intForColumnIndex(0))
            XCTAssert(count == 4)
            results.close()
        }
    }

    func testBatchInsertThroughModelsPrimaryKey(){

        let session = amigo.session

        let w1 = Workout()
        w1.id = 1
        w1.label = "foo"

        let w2 = Workout()
        w2.id = 2
        w2.label = "bar"

        let e1 = WorkoutExercise()
        e1.id = 1
        e1.label = "Jumping Jacks"

        let e2 = WorkoutExercise()
        e2.id = 2
        e2.label = "Push-Ups"

        let m1 = WorkoutMeta()
        m1.id = 1
        m1.workout = w1
        m1.exercise = e1
        m1.duration = 60000
        m1.position = 1

        let m2 = WorkoutMeta()
        m2.id = 2
        m2.workout = w1
        m2.exercise = e2
        m2.duration = 15
        m2.position = 2

        // intentionally add a new WorkoutMeta with
        // a different parent workout
        // so the id of the final WorkoutMeta will
        // not be consecutive
        let m3 = WorkoutMeta()
        m3.id = 3
        m3.workout = w2
        m3.exercise = e2
        m3.duration = 60
        m3.position = 1

        let m4 = WorkoutMeta()
        m4.id = 4
        m4.workout = w1
        m4.exercise = e2
        m4.duration = 25
        m4.position = 3

        session.batch{ batch in
            batch.add([m1, m2, m3, m4], upsert: true)
        }

        XCTAssert(session.query(WorkoutMeta).all().count == 4)

        let sql = "SELECT COUNT(*) FROM amigotests_workout_amigotests_workoutexercise"

        amigo.execute(sql, params: nil){ (results: FMResultSet) -> () in
            results.next()
            let count = Int(results.intForColumnIndex(0))
            XCTAssert(count == 4)
            results.close()
        }
    }

    func testAddManyToMany(){

        let session = amigo.session

        let p1 = Parent()
        p1.label = "foo"

        let p2 = Parent()
        p2.label = "bar"

        let c1 = Child()
        c1.label = "baz"

        session.add(p1)
        session.add(p2)
        session.add(c1)

        session.using(p1).relationship("children").add(c1)
        session.using(p2).relationship("children").add(c1)

        let parents = session
            .query(Parent)
            .using(c1)
            .relationship("parents")
            .all()

        XCTAssertEqual(parents.count, 2)
    }

    func testDeleteManyToMany(){

        let session = amigo.session

        let p1 = Parent()
        p1.label = "foo"

        let p2 = Parent()
        p2.label = "bar"

        let c1 = Child()
        c1.label = "baz"

        session.add(p1)
        session.add(p2)
        session.add(c1)

        session.using(p1).relationship("children").add(c1)
        session.using(p2).relationship("children").add(c1)

        var parents = session
            .query(Parent)
            .using(c1)
            .relationship("parents")
            .all()

        XCTAssertEqual(parents.count, 2)

        session.using(c1).relationship("parents").delete(p2)

        parents = session
            .query(Parent)
            .using(c1)
            .relationship("parents")
            .all()
        
        XCTAssertEqual(parents.count, 1)
        XCTAssertEqual(parents[0].label, "foo")
    }

    func testManyToManyThroughModelAdd(){

        let session = amigo.session

        let w1 = Workout()
        w1.label = "foo"

        let w2 = Workout()
        w2.label = "bar"

        let e1 = WorkoutExercise()
        e1.label = "Jumping Jacks"

        let e2 = WorkoutExercise()
        e2.label = "Push-Ups"

        let m1 = WorkoutMeta()
        m1.workout = w1
        m1.exercise = e1
        m1.duration = 60000
        m1.position = 1

        let m2 = WorkoutMeta()
        m2.workout = w1
        m2.exercise = e2
        m2.duration = 15
        m2.position = 2

        // intentionally add a new WorkoutMeta with
        // a different parent workout
        // so the id of the final WorkoutMeta will
        // not be consecutive
        let m3 = WorkoutMeta()
        m3.workout = w2
        m3.exercise = e2
        m3.duration = 60
        m3.position = 1

        let m4 = WorkoutMeta()
        m4.workout = w1
        m4.exercise = e2
        m4.duration = 25
        m4.position = 3

        session.add(w1)
        session.add(w2)
        session.add(e1)
        session.add(e2)
        session.add(m1)
        session.add(m2)
        session.add(m3)
        session.add(m4)

        let results = session
            // ensure we get back everything possible re: the selectRelated
            // you would likely only need "exercise" here not
            // "exercise" and "workout" as we are `using(w1)` already
            // to generate the query.

            .query(WorkoutMeta)
            .using(w1)
            .selectRelated("exercise", "workout")
            .relationship("exercises")
            .orderBy("position", ascending: false)
            .all()

        XCTAssertEqual(results.count, 3)

        XCTAssertEqual(results[0].id, m4.id)
        XCTAssertEqual(results[0].duration, m4.duration)
        XCTAssertEqual(results[0].position, m4.position)
        XCTAssertNotNil(results[0].exercise)
        XCTAssertEqual(results[0].exercise.id, e2.id)
        XCTAssertEqual(results[0].exercise.label, e2.label)
        XCTAssertNotNil(results[0].workout)
        XCTAssertEqual(results[0].workout.id, w1.id)
        XCTAssertEqual(results[0].workout.label, w1.label)

        XCTAssertEqual(results[1].id, m2.id)
        XCTAssertEqual(results[1].duration, m2.duration)
        XCTAssertEqual(results[1].position, m2.position)
        XCTAssertNotNil(results[1].exercise)
        XCTAssertEqual(results[1].exercise.id, e2.id)
        XCTAssertEqual(results[1].exercise.label, e2.label)
        XCTAssertNotNil(results[1].workout)
        XCTAssertEqual(results[1].workout.id, w1.id)
        XCTAssertEqual(results[1].workout.label, w1.label)

        XCTAssertEqual(results[2].id, m1.id)
        XCTAssertEqual(results[2].duration, m1.duration)
        XCTAssertEqual(results[2].position, m1.position)
        XCTAssertNotNil(results[2].exercise)
        XCTAssertEqual(results[2].exercise.id, e1.id)
        XCTAssertEqual(results[2].exercise.label, e1.label)
        XCTAssertNotNil(results[2].workout)
        XCTAssertEqual(results[2].workout.id, w1.id)
        XCTAssertEqual(results[2].workout.label, w1.label)
    }

    func testManyToManyThroughModelDelete(){

        let session = amigo.session

        let w1 = Workout()
        w1.label = "foo"

        let e1 = WorkoutExercise()
        e1.label = "Jumping Jacks"

        let e2 = WorkoutExercise()
        e2.label = "Push-Ups"

        let m1 = WorkoutMeta()
        m1.workout = w1
        m1.exercise = e1
        m1.duration = 60000
        m1.position = 1

        let m2 = WorkoutMeta()
        m2.workout = w1
        m2.exercise = e2
        m2.duration = 15
        m2.position = 2

        let m3 = WorkoutMeta()
        m3.workout = w1
        m3.exercise = e2
        m3.duration = 25
        m3.position = 3


        session.add(w1)
        session.add(e1)
        session.add(e2)
        session.add(m1)
        session.add(m2)
        session.add(m3)

        var results = session
            .query(WorkoutMeta)
            .using(w1)
            .selectRelated("exercise")
            .relationship("exercises")
            .orderBy("position", ascending: false)
            .all()

        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].id, m3.id)

        session.delete(m3)

        results = session
            .query(WorkoutMeta)
            .using(w1)
            .selectRelated("exercise")
            .relationship("exercises")
            .orderBy("position", ascending: false)
            .all()
        
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].id, m2.id)
    }

    func testManyToManyThroughModelAddRejected(){

        let session = amigo.session

        let w1 = Workout()
        w1.label = "foo"

        let e1 = WorkoutExercise()
        e1.label = "Jumping Jacks"

        session.add(w1)
        session.add(e1)

        session.using(w1).relationship("exercises").add(e1)
        
    }
    
}
