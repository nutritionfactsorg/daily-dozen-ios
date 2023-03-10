//
//  SqliteConnector.swift
//  SqliteMigrateLegacy
//

import Foundation
import SQLiteApi

struct SqliteConnector {
    static var run = SqliteConnector()
    
    init() {
        let sqliteApi = SQLiteApi()
        print(sqliteApi.text)
    }
    
    func clearDb() {
        print("run clearDb")
    }

    func createData() {
        print("run createData")
    }

    func exportData() {
        print("run exportData")
    }

    func importData() {
        print("run importData")
    }
    
    func timingTest() {
        print("run timingTest")
    }
    
}

