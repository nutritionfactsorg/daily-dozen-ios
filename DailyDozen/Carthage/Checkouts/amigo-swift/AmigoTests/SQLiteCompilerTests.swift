//
//  SQLiteCompilerTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/7/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
@testable import Amigo




class SQLiteCompilerTests: AmigoTestBase {
    let meta = MetaData()
    var sqliteEngine: Engine!

    override func setUp() {
        super.setUp()
        sqliteEngine = engine.engine
    }

    func testCreateTable() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("name", type: String.self)
        )

        let sql = sqliteEngine.compiler.compile(CreateTable(t1))
        let expected = "CREATE TABLE IF NOT EXISTS dogs (" +
              "\n\t" + "id INTEGER PRIMARY KEY NOT NULL," +
              "\n\t" + "name TEXT NULL" +
                "\n" + ");"

        XCTAssertEqual(sql, expected)
    }

    func testCreateTableWithIndex() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("name", type: String.self),
            Column("color", type: String.self),
            Index("dogs_name_idx", "name"),
            Index("dogs_color_idx", "color")
        )
        
        let sql = sqliteEngine.compiler.compile(CreateTable(t1))
        let expected = "CREATE TABLE IF NOT EXISTS dogs (" +
            "\n\t" + "id INTEGER PRIMARY KEY NOT NULL," +
            "\n\t" + "name TEXT NULL," +
            "\n\t" + "color TEXT NULL" +
            "\n" + ");" +
            "\n" + "CREATE INDEX IF NOT EXISTS dogs_name_idx ON dogs (name);" +
            "\n" + "CREATE INDEX IF NOT EXISTS dogs_color_idx ON dogs (color);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateColumnOptional() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self)
        )

        let sql = sqliteEngine.compiler.compile(CreateColumn(t1.c["id"]!))
        let expected = "id INTEGER NULL"

        XCTAssertEqual(sql, expected)
    }

    func testCreateColumnRequired() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, optional: false)
        )

        let sql = sqliteEngine.compiler.compile(CreateColumn(t1.c["id"]!))
        let expected = "id INTEGER NOT NULL"

        XCTAssertEqual(sql, expected)
    }

    func testCreateColumnPrimaryKey() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true)
        )

        let sql = sqliteEngine.compiler.compile(CreateColumn(t1.c["id"]!))
        let expected = "id INTEGER PRIMARY KEY NOT NULL"

        XCTAssertEqual(sql, expected)
    }

    func testCreateColumnForeignKeyOptional() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: String.self, primaryKey: true)
        )

        let t2 = Table("people", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("dog_id", type: ForeignKey(t1))
        )

        XCTAssertEqual(t2.indexes.count, 1)

        let column = sqliteEngine.compiler.compile(CreateColumn(t2.c["dog_id"]!))
        let index = sqliteEngine.compiler.compile(CreateIndex(t2.indexes[0]))
        let expectedColumn = "dog_id TEXT NULL"
        let expectedIndex = "CREATE INDEX IF NOT EXISTS people_dog_id_idx ON people (dog_id);"

        XCTAssertEqual(column, expectedColumn)
        XCTAssertEqual(index, expectedIndex)
    }

    func testCreateColumnForeignKeyRequired() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: String.self, primaryKey: true)
        )

        let t2 = Table("people", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("dog_id", type: ForeignKey(t1), optional:false)
        )

        let sql = sqliteEngine.compiler.compile(CreateColumn(t2.c["dog_id"]!))
        let expected = "dog_id TEXT NOT NULL"

        XCTAssertEqual(sql, expected)
    }

    func testCreateIndexImplicit() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, indexed: true)
        )

        let sql = sqliteEngine.compiler.compile(CreateIndex(t1.indexes[0]))
        let expected = "CREATE INDEX IF NOT EXISTS dogs_id_idx ON dogs (id);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateIndexSingle() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self),
            Index("dogs_id_idx", "id")
        )

        let sql = sqliteEngine.compiler.compile(CreateIndex(t1.indexes[0]))
        let expected = "CREATE INDEX IF NOT EXISTS dogs_id_idx ON dogs (id);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateIndexMultiple() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self),
            Column("label", type: String.self),
            Index("dogs_id_idx", "id", "label")
        )

        let sql = sqliteEngine.compiler.compile(CreateIndex(t1.indexes[0]))
        let expected = "CREATE INDEX IF NOT EXISTS dogs_id_idx ON dogs (id, label);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateIndexUnique() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self),
            Column("label", type: String.self),
            Index("dogs_id_idx", unique: true, "id")
        )

        let sql = sqliteEngine.compiler.compile(CreateIndex(t1.indexes[0]))
        let expected = "CREATE UNIQUE INDEX IF NOT EXISTS dogs_id_idx ON dogs (id);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateIndexFromColumn() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self, indexed: true)
        )

        let sql = sqliteEngine.compiler.compile(CreateIndex(t1.indexes[0]))
        let expected = "CREATE INDEX IF NOT EXISTS dogs_label_idx ON dogs (label);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateUniqueIndexFromColumn() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self, indexed: true, unique: true)
        )

        let sql = sqliteEngine.compiler.compile(CreateIndex(t1.indexes[0]))
        let expected = "CREATE UNIQUE INDEX IF NOT EXISTS dogs_label_idx ON dogs (label);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateJoin() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let t2 = Table("people", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            Column("dog_id", type: ForeignKey(t1))
        )

        let join = t2.join(t1)
        let sql = sqliteEngine.compiler.compile(join)
        let expected = "LEFT JOIN dogs ON people.dog_id = dogs.id"

        XCTAssertEqual(sql, expected)
    }

    func testCreateSelect() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let select = Select(t1)
        let sql = sqliteEngine.compiler.compile(select)
        let expected = "SELECT dogs.id as 'dogs.id', dogs.label as 'dogs.label'" +
                "\n" + "FROM dogs;"

        XCTAssertEqual(sql, expected)
    }

    func testCreateInsert() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let insert = Insert(t1)
        let sql = sqliteEngine.compiler.compile(insert)
        let expected = "INSERT INTO dogs (label) VALUES (?);"

        XCTAssertEqual(sql, expected)
    }

    func testCreateUpsert() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let insert = Insert(t1, upsert: true)
        let sql = sqliteEngine.compiler.compile(insert)
        let expected = "INSERT OR REPLACE INTO dogs (id, label) VALUES (?, ?);"

        XCTAssertEqual(sql, expected)

    }

    func testCreateSelectSingleJoin() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let t2 = Table("people", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            Column("dog_id", type: ForeignKey(t1))
        )

        let j1 = t2.join(t1)
        let select = Select(t2, t1).selectFrom(j1)

        let sql = sqliteEngine.compiler.compile(select)

        let expected = "SELECT people.id as 'people.id', people.label as 'people.label', people.dog_id as 'people.dog_id', dogs.id as 'dogs.id', dogs.label as 'dogs.label'" +
                "\n" + "FROM people" +
                "\n" + "LEFT JOIN dogs ON people.dog_id = dogs.id;"

        XCTAssertEqual(sql, expected)
    }

    func testCreateSelectMultipleJoin() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let t2 = Table("cats", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let t3 = Table("people", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            Column("dog_id", type: ForeignKey(t1)),
            Column("cat_id", type: ForeignKey(t2))
        )

        let j1 = t3.join(t1)
        let j2 = t3.join(t2)
        let select = Select(t3, t1, t2).selectFrom(j1, j2)


        let sql = sqliteEngine.compiler.compile(select)

        let expected = "SELECT people.id as 'people.id', people.label as 'people.label', people.dog_id as 'people.dog_id', people.cat_id as 'people.cat_id', dogs.id as 'dogs.id', dogs.label as 'dogs.label', cats.id as 'cats.id', cats.label as 'cats.label'" +
                "\n" + "FROM people" +
                "\n" + "LEFT JOIN dogs ON people.dog_id = dogs.id" +
                "\n" + "LEFT JOIN cats ON people.cat_id = cats.id;"

        XCTAssertEqual(sql, expected)
    }

    func testComparisionPredicateColumns() {
        let query = amigo.query(Dog).filter("id = label")
        let table = amigo.tableIndex["dog"]!.table

        if let(sql, params) = query.compileFilter(table){
            XCTAssertEqual("amigotests_dog.id = amigotests_dog.label", sql)
            print(sql)
            print(params)
            XCTAssert(params.count == 0)
        } else {
            XCTFail()
        }
    }

    func testComparisionPredicateEqual() {
        let query = amigo.query(Dog).filter("id = 1")
        let table = amigo.tableIndex["dog"]!.table

        if let(sql, params) = query.compileFilter(table){
            XCTAssertEqual("amigotests_dog.id = ?", sql)
            XCTAssert(params.count == 1)
            XCTAssert(params[0].integerValue == 1)
        } else {
            XCTFail()
        }
    }

    func testComparisionPredicateGreaterThan() {
        let query = amigo.query(Dog).filter("id > 1")
        let table = amigo.tableIndex["dog"]!.table

        if let(sql, params) = query.compileFilter(table){
            XCTAssertEqual("amigotests_dog.id > ?", sql)
            XCTAssert(params.count == 1)
            XCTAssert(params[0].integerValue == 1)
        } else {
            XCTFail()
        }
    }

    func testComparisionPredicateGreaterThanEqual() {
        let query = amigo.query(Dog).filter("id >= 1")
        let table = amigo.tableIndex["dog"]!.table

        if let(sql, params) = query.compileFilter(table){
            XCTAssertEqual("amigotests_dog.id >= ?", sql)
            XCTAssert(params.count == 1)
            XCTAssert(params[0].integerValue == 1)
        } else {
            XCTFail()
        }
    }

    func testComparisionPredicateLessThan() {
        let query = amigo.query(Dog).filter("id < 1")
        let table = amigo.tableIndex["dog"]!.table

        if let(sql, params) = query.compileFilter(table){
            XCTAssertEqual("amigotests_dog.id < ?", sql)
            XCTAssert(params.count == 1)
            XCTAssert(params[0].integerValue == 1)
        } else {
            XCTFail()
        }
    }

    func testComparisionPredicateLessThanEqual() {
        let query = amigo.query(Dog).filter("id <= 1")
        let table = amigo.tableIndex["dog"]!.table

        if let(sql, params) = query.compileFilter(table){
            XCTAssertEqual("amigotests_dog.id <= ?", sql)
            XCTAssert(params.count == 1)
            XCTAssert(params[0].integerValue == 1)
        } else {
            XCTFail()
        }
    }

    func testComparisionPredicateForeignKey() {
        let query = amigo.query(People).selectRelated("dog").filter("dog.id = 1")
        let table = amigo.tableIndex["dog"]!.table

        if let(sql, params) = query.compileFilter(table){
            XCTAssertEqual("amigotests_dog.id = ?", sql)
            XCTAssert(params.count == 1)
            XCTAssert(params[0].integerValue == 1)
        } else {
            XCTFail()
        }
    }

    func testCompoundPredicate() {
        // (id > 1 AND id < 20) OR id == 22 OR (id == 26 AND id != 15)
        let query = amigo.query(Dog).filter("id > 1 && id < 20 || id = 22 OR id = 26 AND id != 15")

        //let query = amigo.query(Dog).filter("id > 1 and id < 20")

        let table = amigo.tableIndex["dog"]!.table

        if let(sql, params) = query.compileFilter(table){
            let expected = "(amigotests_dog.id > ? AND amigotests_dog.id < ?) OR amigotests_dog.id = ? OR (amigotests_dog.id = ? AND amigotests_dog.id != ?)"
            XCTAssertEqual(expected, sql)
            XCTAssert(params.count == 5)
            XCTAssert(params.map{$0.integerValue} == [1, 20, 22, 26, 15])
        } else {
            XCTFail()
        }
    }

}
