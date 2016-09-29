//
//  SQLiteCompiler.swift
//  Amigo
//
//  Created by Adam Venturella on 7/7/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData

public struct PredicateContext{
    let predicate: NSPredicate
    let table: Table
    let models: [String: ORMModel]

    public var comparisionPredicate: NSComparisonPredicate{
        return predicate as! NSComparisonPredicate
    }

    public var compoundPredicate: NSCompoundPredicate{
        return predicate as! NSCompoundPredicate
    }
}

public struct ExpressionContext{
    let expression: NSExpression
    let table: Table
    let models: [String: ORMModel]

    public static func fromComparisionContext(context: PredicateContext)
        -> (ExpressionContext, ExpressionContext){
        let exp = context.comparisionPredicate
        let left = ExpressionContext(expression: exp.leftExpression, table: context.table, models: context.models)
        let right = ExpressionContext(expression: exp.rightExpression, table: context.table, models: context.models)

        return (left, right)
    }
}

public struct ExpressionMeta{
    let label: String
    let value: AnyObject?
    let column: Column?
}

public struct SQLiteCompiler: Compiler{
    public let typeCompiler = SQLiteTypeCompiler()

    public func compile(expression: CreateTable) -> String{
        let table = expression.element
        let preamble = "CREATE TABLE IF NOT EXISTS \(table.label)"
        let columnsSql = expression.columns.map(compile)
        let indexSql = table.indexes.map{compile(CreateIndex($0))}

        let columns =  columnsSql.map{"\n\t\($0)"}.joinWithSeparator(",")
        let indexes = indexSql.joinWithSeparator("\n")

        var sql = "\(preamble) (\(columns)\n);"

        if indexes.characters.count > 0{
            sql = "\(sql)\n\(indexes)"
        }

        return sql
    }

    public func compile(expression: CreateColumn) -> String{
        let column = expression.element
        let type = typeCompiler.process(column.type)
        var options = [String]()
        let joinedOptions: String
        let sql: String

        if column.primaryKey{
            options.append("PRIMARY KEY")
            options.append("NOT NULL")
        } else {
            options.append(column.optional ? "NULL" : "NOT NULL")
        }

        joinedOptions = options.joinWithSeparator(" ")
        sql = "\(column.label) \(type) \(joinedOptions)"

        return sql
    }

    public func compile(expression: CreateIndex) -> String{
        let preamble: String
        let result: String
        let index = expression.element
        let table = index.table!
        let on = "ON \(table.label)"


        if index.unique{
            preamble = "CREATE UNIQUE INDEX IF NOT EXISTS"
        } else {
            preamble = "CREATE INDEX IF NOT EXISTS"
        }

        let columns = index.columns.map{$0.label}.joinWithSeparator(", ")

        result = "\(preamble) \(index.label) \(on) (\(columns));"

        return result
    }

    public func compile(expression: Join) -> String{
        let right = expression.right
        return "LEFT JOIN \(right.label) ON \(expression.on)"
    }

    public func compile(expression: Select) -> String{

        let columnsSql = expression.columns.map{ "\($0.qualifiedLabel!) as '\($0.qualifiedLabel!)'"}
        let joinsSql = expression.from.filter{ $0 is Join }.map{ compile($0 as! Join)}
        let tablesSql = expression.from.filter{ $0 is Table }.map{ value -> String in
            let t = value as! Table
            return t.label
        }

        let columns = "SELECT " + columnsSql.joinWithSeparator(", ")
        let tables = "\nFROM " +  tablesSql.joinWithSeparator(", ")
        let joins = joinsSql.map{"\n" + $0 }.joinWithSeparator("")
        let filter: String
        let limit: String
        let offset: String
        let orderBy: String

        if let predicate = expression.predicate{
            filter = "\nWHERE " + predicate
        } else {
            filter = ""
        }

        let orderParts = expression._orderBy.map{ (value: OrderBy) -> String in
            if value  is Asc{
                return "\(value.keyPath) ASC"
            } else {
                return "\(value.keyPath) DESC"
            }
        }

        if orderParts.count > 0{
            orderBy = "\nORDER BY " + orderParts.joinWithSeparator(", ")
        } else {
            orderBy = ""
        }

        if let value = expression._limit{
            limit = "\nLIMIT \(value)"
        } else {
            limit = ""
        }

        if let value = expression._offset{
            offset = "\nOFFSET \(value)"
        } else {
            offset = ""
        }
        

        let sql = columns + tables + joins +  filter + orderBy + limit + offset + ";"
        return sql
    }

    public func compile(expression: Insert) -> String {
        var columnLabels = [String]()
        var placeholders = [String]()


        for each in expression.table.sortedColumns{

            if each.primaryKey {
                
                // Auto Increment  (Integer Primary Key)
                // Don't include it, Sqlite will do it.
                if each.type == .Integer64AttributeType{
                    if expression.upsert == false {
                        continue
                    } else {
                        columnLabels.append(each.label)
                        placeholders.append("?")
                        continue
                    }
                }

                // Upsert means that we will need the primary key
                // column in the insert sql. If it's not an upsert
                // we do not want to include the primary key
                // column into the insert sql UNLESS there is a default
                // value. We never make it to this decision tree
                // if the user provides the pk for the model
                // as it will be considered an update, not an insert.
                if expression.upsert == false{
                    if let _ = each.defaultValue {
                        columnLabels.append(each.label)
                        placeholders.append("?")
                        continue
                    } else {
                        continue
                    }
                }
            }

            columnLabels.append(each.label)
            placeholders.append("?")
        }

        let columnData = columnLabels.joinWithSeparator(", ")
        let placeholderData = placeholders.joinWithSeparator(", ")
        let orReplace = expression.upsert ? "OR REPLACE INTO" : "INTO"

        let sql = "INSERT \(orReplace) \(expression.table.label) (\(columnData)) VALUES (\(placeholderData));"
        return sql
    }

    public func compile(expression: Delete) -> String {
        let prefix = "DELETE FROM \(expression.table.label)"

        let filter: String

        if let predicate = expression.predicate{
            filter = "\nWHERE " + predicate
        } else {
            filter = ""
        }


        let sql = prefix + filter + ";"
        return sql
    }

    public func compile(expression: Update) -> String {
        let prefix = "UPDATE \(expression.table.label) SET "
        var each = [String]()
        let columns: String
        let filter: String

        for column in expression.table.sortedColumns{
            if column.primaryKey && column.type == .Integer64AttributeType{
                continue
            }

            each.append("\(column.label) = ?")
        }

        columns = each.joinWithSeparator(", ")

        if let predicate = expression.predicate{
            filter = "\nWHERE " + predicate
        } else {
            filter = ""
        }


        let sql = prefix + columns + filter + ";"
        return sql
    }

    public func compile(expression: NSPredicate, table: Table, models:[String: ORMModel]) -> (String, [AnyObject]){

        let context = PredicateContext(predicate: expression, table: table, models: models)
        return compile(context)
    }

    public func compile(context: PredicateContext) -> (String, [AnyObject]){
        var params = [AnyObject]()
        var sql = [String]()

        switch context.predicate{
        case is NSComparisonPredicate:
            let (str, args) = compileComparisonPredicate(context)
            sql.append(str)
            params = params + args.flatMap{$0}

        case is NSCompoundPredicate:
            let (str, args) = compileCompoundPredicate(context)
            sql.append(str)
            params = params + args.flatMap{$0}
        default:()
        }

        return (sql.joinWithSeparator(" "), params)
    }

    //public func compile(context: ExpressionContext) -> (AnyObject, AnyObject?){
    public func compile(context: ExpressionContext) -> ExpressionMeta{
        let expression = context.expression

        switch expression.expressionType{
        case .ConstantValueExpressionType:
            return ExpressionMeta(label: "?", value: expression.constantValue, column: nil )
        case .KeyPathExpressionType:

            let parts = expression.keyPath.unicodeScalars.split{$0 == "."}.map(String.init).map{$0.lowercaseString}
            let column: Column

            if parts.count == 1{
                column = context.table.columns[parts[0]]!
            } else if parts.count == 2{
                if let model = context.table.model{
                    let table = model.foreignKeys[parts[0]]!.foreignKey!.relatedTable
                    column = table.columns[parts[1]]!
                } else {
                    let target = context.table.columns[parts[0]]!
                    let suffix = target.foreignKey!.relatedColumn.label
                    let key = parts[0] + "_\(suffix)"
                    column = context.table.columns[key]!.foreignKey!.relatedTable.columns[parts[1]]!
                }
            } else { // fully qualified (count = 3) namespace | table | column
                let target = context.table.columns[parts[1]]!
                let suffix = target.foreignKey!.relatedColumn.label
                let key = parts[1] + "_\(suffix)"
                column = context.table.columns[key]!.foreignKey!.relatedColumn
            }

            return ExpressionMeta(label: column.qualifiedLabel!, value: nil, column: column)

        case .EvaluatedObjectExpressionType: fallthrough
        case .VariableExpressionType: fallthrough
        case .FunctionExpressionType: fallthrough
        case .UnionSetExpressionType: fallthrough
        case .IntersectSetExpressionType: fallthrough
        case .MinusSetExpressionType: fallthrough
        case .SubqueryExpressionType: fallthrough
        case .AggregateExpressionType: fallthrough
        case .AnyKeyExpressionType: fallthrough
        case .BlockExpressionType: fallthrough
        default:
            return ExpressionMeta(label: "", value: nil, column: nil)
        }

    }

    public func compileComparisonPredicate(context: PredicateContext) -> (String, [AnyObject?]){

        let (left, right) = ExpressionContext.fromComparisionContext(context)

        let metaLeft = compile(left)
        let metaRight = compile(right)

        let params: [AnyObject?]

        if let column = metaLeft.column{
            if let fk = column.foreignKey{
                params = [fk.relatedColumn.serialize(metaRight.value)]
            } else {
                params = [column.serialize(metaRight.value)]
            }
        } else {
            params = []
        }
        //let params = [metaLeft.column?.serialize(metaRight.value)]

        let sql = compile(context.comparisionPredicate.predicateOperatorType, left: metaLeft.label, right: metaRight.label)

        return (sql, params)
    }

    public func compileCompoundPredicate(context: PredicateContext) -> (String, [AnyObject?]){
        let compound = context.compoundPredicate
        // "id > 1 && id < 20 || id = 22 OR id = 26 AND id != 15"
        var params = [AnyObject?]()
        var sql = [String]()
        let join: String


        switch compound.compoundPredicateType{
        case .AndPredicateType:
            join = "AND"
        case .OrPredicateType:
            join = "OR"
        case .NotPredicateType:
            join = "NOT"
        }

        compound.subpredicates.forEach{ value -> () in
            let predicate = value as! NSPredicate
            let context = PredicateContext(predicate:predicate , table: context.table, models: context.models)
            let (_sql, _params) = compile(context)
            sql = sql + [_sql]
            params = params + _params.map{Optional.Some($0)}
        }

        let stmt =  sql.joinWithSeparator(" \(join) ")

        if compound.compoundPredicateType == .AndPredicateType{
            return ("(\(stmt))", params)
        }

        return (stmt, params)
    }

    public func compile(expression: NSPredicateOperatorType, left: AnyObject, right: AnyObject) -> String{
        // https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html
        switch expression{
        case .LessThanPredicateOperatorType:
            return "\(left) < \(right)"
        case .LessThanOrEqualToPredicateOperatorType:
            return "\(left) <= \(right)"
        case .GreaterThanPredicateOperatorType:
            return "\(left) > \(right)"
        case .GreaterThanOrEqualToPredicateOperatorType:
            return "\(left) >= \(right)"
        case .EqualToPredicateOperatorType:
            return "\(left) = \(right)"
        case .NotEqualToPredicateOperatorType:
            return "\(left) != \(right)"
        case .MatchesPredicateOperatorType:
            return "\(left) REGEXP '\(right)'" // TODO test `matches` NSPredicate
        case .LikePredicateOperatorType:
            return "\(left) LIKE \(right)" // TODO test `like` NSPredicate
        case .BeginsWithPredicateOperatorType:
            return "\(left) LIKE \(right)%" // TODO test `beginswith` NSPredicate
        case .EndsWithPredicateOperatorType:
            return "\(left) LIKE '%\(right)" // TODO test `endswith` NSPredicate
        case .InPredicateOperatorType:
            return "\(left) IN (\(right))" // TODO test `in {}` NSPredicate
        case .CustomSelectorPredicateOperatorType:
            return "" // noop?
        case .ContainsPredicateOperatorType:
            return "\(left) LIKE %\(right)%" // TODO test `contains`
        case .BetweenPredicateOperatorType:
            return "\(left) BETWEEN \(right)" // TOFO test `between`, right will be a compound predicate? it needs multiple values
        }
    }
}