//
//  AmigoQuerySetTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/24/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
import Amigo

class AmigoQuerySetTests: AmigoTestBase {


    func testMultipleForeignKeys(){
        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let c1 = Cat()
        c1.label = "Ollie"

        let p1 = People()
        p1.label = "Foo"
        p1.dog = d1
        p1.cat = c1

        session.add(p1)

        let people = session
            .query(People)
            .selectRelated("dog", "cat")
            .all()

        XCTAssertEqual(people.count, 1)
        XCTAssertNotNil(people[0].dog)
        XCTAssertNotNil(people[0].cat)
        XCTAssertEqual(people[0].dog.label, "Lucy")
        XCTAssertEqual(people[0].cat.label, "Ollie")
    }

    func testOrderByDifferentTable(){
        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let d2 = Dog()
        d2.label = "Ollie"

        let p1 = People()
        p1.label = "Foo"
        p1.dog = d1

        let p2 = People()
        p2.label = "Bar"
        p2.dog = d2

        session.add(p1)
        session.add(p2)

        let people = session
            .query(People)
            .selectRelated("dog")
            .orderBy("dog.label", ascending: false)
            .all()

        XCTAssertEqual(people.count, 2)
        XCTAssertEqual(people[0].id, 2)
        XCTAssertEqual(people[0].dog.label, "Ollie")
    }

    func testFilterBy(){
        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let d2 = Dog()
        d2.label = "Ollie"

        let p1 = People()
        p1.label = "Foo"
        p1.dog = d1

        let p2 = People()
        p2.label = "Bar"
        p2.dog = d2

        session.add(p1)
        session.add(p2)

        let people = session
            .query(People)
            .filter("label = 'Foo'")
            .all()

        XCTAssertEqual(people.count, 1)
        XCTAssertEqual(people[0].id, 1)
    }

    func testFilterByDifferentTable(){
        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let d2 = Dog()
        d2.label = "Ollie"

        let p1 = People()
        p1.label = "Foo"
        p1.dog = d1

        let p2 = People()
        p2.label = "Bar"
        p2.dog = d2

        session.add(p1)
        session.add(p2)

        let people = session
            .query(People)
            .selectRelated("dog")
            .orderBy("dog.label", ascending: false)
            .filter("dog.label = \"Lucy\"")
            .all()

        XCTAssertEqual(people.count, 1)
        XCTAssertEqual(people[0].id, 1)
        XCTAssertEqual(people[0].dog.label, "Lucy")
    }

    func testOrderBySameTable(){
        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let d2 = Dog()
        d2.label = "Ollie"

        session.add(d1)
        session.add(d2)

        var dogs = session
            .query(Dog)
            .orderBy("label", ascending: false)
            .all()

        XCTAssertEqual(dogs.count, 2)
        XCTAssertEqual(dogs[0].id, 2)
        XCTAssertEqual(dogs[0].label, "Ollie")

        dogs = session
            .query(Dog)
            .orderBy("label")
            .all()

        XCTAssertEqual(dogs.count, 2)
        XCTAssertEqual(dogs[0].id, 1)
        XCTAssertEqual(dogs[0].label, "Lucy")
    }

    func testForeignKeyAutoSave(){
        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let p1 = People()
        p1.label = "Ollie Cat"
        p1.dog = d1

        var candidate = session.query(Dog).get(1)
        XCTAssertNil(candidate)

        session.add(p1)

        candidate = session.query(Dog).get(1)
        XCTAssertNotNil(candidate)
    }

    func testSelectRelated(){
        let session = amigo.session

        let d1 = Dog()
        d1.label = "Lucy"

        let p1 = People()
        p1.label = "Ollie Cat"
        p1.dog = d1

        session.add(p1)

        var person = session.query(People).get(1)!
        XCTAssertNil(person.dog)

        person = session
            .query(People)
            .selectRelated("dog")
            .get(1)!

        XCTAssertNotNil(person.dog)
        XCTAssertEqual(person.dog.label, "Lucy")
    }

    func testLimit(){
        let session = amigo.session

        let a1 = Author()
        a1.firstName = "Lucy"
        a1.lastName = "Dog"

        let a2 = Author()
        a2.firstName = "Ollie"
        a2.lastName = "Cat"

        session.add(a1)
        session.add(a2)

        let authors = session
            .query(Author)
            .limit(1)
            .all()

        XCTAssertEqual(authors.count, 1)
        XCTAssertEqual(authors[0].firstName, "Lucy")
        XCTAssertEqual(authors[0].lastName, "Dog")
    }

    func testOffset(){
        let session = amigo.session

        let a1 = Author()
        a1.firstName = "Lucy"
        a1.lastName = "Dog"

        let a2 = Author()
        a2.firstName = "Ollie"
        a2.lastName = "Cat"

        session.add(a1)
        session.add(a2)

        let authors = session
            .query(Author)
            .limit(1)
            .offset(1)
            .all()

        XCTAssertEqual(authors.count, 1)
        XCTAssertEqual(authors[0].firstName, "Ollie")
        XCTAssertEqual(authors[0].lastName, "Cat")
    }

    func testOneToMany(){

        let session = amigo.session

        let a1 = Author()
        a1.firstName = "Lucy"
        a1.lastName = "Dog"

        let a2 = Author()
        a2.firstName = "Ollie"
        a2.lastName = "Cat"
        
        let p1 = Post()
        p1.title = "The Story of Barking"
        p1.author = a1

        let p2 = Post()
        p2.title = "10 Things You Should Know When Chasing Squirrels"
        p2.author = a1

        let p3 = Post()
        p3.title = "The Story of Being a Cat"
        p3.author = a2

        session.add(a1)
        session.add(a2)
        session.add(p1)
        session.add(p2)
        session.add(p3)

        let posts = session.query(Post)
            .using(a1)
            .relationship("posts")
            .all()

        XCTAssertEqual(posts.count, 2)
    }
}
