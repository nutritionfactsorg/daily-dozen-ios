//
//  Compiler.swift
//  Amigo
//
//  Created by Adam Venturella on 7/7/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public protocol Compiler{
    func compile(expression: CreateTable) -> String
    func compile(expression: CreateColumn) -> String
    func compile(expression: CreateIndex) -> String
    func compile(expression: Join) -> String
    func compile(expression: Select) -> String
    func compile(expression: Insert) -> String
    func compile(expression: Update) -> String
    func compile(expression: Delete) -> String
    func compile(expression: NSPredicate, table: Table, models: [String: ORMModel]) -> (String, [AnyObject])
}