//
//  Select.swift
//  Amigo
//
//  Created by Adam Venturella on 7/7/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public func ==(lhs: Join, rhs: Join) -> Bool{
    return lhs.hashValue == rhs.hashValue
}

public func ==(lhs: Select, rhs: Select) -> Bool{
    return lhs.hashValue == rhs.hashValue
}


public protocol FromClause: Hashable, CustomStringConvertible{

}

extension Table {
    public func join(table: Table) -> Join{

        let joins = Array(self.columns.values)
            .filter{ $0.foreignKey?.relatedColumn == table.primaryKey }
            .map{ column -> Join in
                let fk = column.foreignKey!
                let format = "\(self.label).\(fk.column.label) = \(table.label).\(table.primaryKey!.label)"
                return self.join(table, on: format)
            }
        
        return joins[0]
    }
}

extension FromClause{

    public var hashValue: Int{
        return description.hashValue
    }

//    public func join(table: Table) -> Join{
//        guard let current = self as? Table else{
//            fatalError("Cannot join from non-table: \(self)")
//        }
//
//        let format = "\(current.label).\(current.primaryKey!.label) = \(table.label).\(table.primaryKey!.label)"
//        return self.join(table, on: format)
//    }

    public func join(table: Table, on: String, _ args: AnyObject...) -> Join{
        return self.join(table, on: on, args: args)
    }

    public func join(table: Table, on: String, args: [AnyObject]?) -> Join{
        guard let current = self as? Table else{
            fatalError("Cannot join from non-table: \(self)")
        }

        return Join(current, right: table, on: on)
    }

    public func select() -> Select{
        if let table = self as? Table{
            return Select(table)
        }

        fatalError("Cannot select from non-table: \(self)")
    }

    public func insert() -> Insert{
        if let table = self as? Table{
            return Insert(table)
        }

        fatalError("Cannot insert from non-table: \(self)")
    }

    public func insert(upsert upsert: Bool) -> Insert{
        if let table = self as? Table{
            return Insert(table, upsert: upsert)
        }

        fatalError("Cannot insert from non-table: \(self)")
    }


    public func update() -> Update{
        if let table = self as? Table{
            return Update(table)
        }

        fatalError("Cannot update from non-table: \(self)")
    }

    public func delete() -> Delete{
        if let table = self as? Table{
            return Delete(table)
        }

        fatalError("Cannot delete from non-table: \(self)")
    }
}


public class Join: FromClause{
    public let left: Table
    public let right: Table
    public let on: String

    public init(_ left: Table, right: Table, on: String){
        self.left = left
        self.right = right
        self.on = on
    }

    public var description: String{
        return "<Join: left:\(left.label) right:\(right.label)>"
    }
}


public class Select: FromClause, Filterable{

    public let columns: [Column]
    // swift doesn't have an ordered set in it's stdlib so 
    // we fake it
    public var from = [AnyObject]()
    public var predicate: String?
    public var predicateParams: [AnyObject]?

    var hasFrom = [String: AnyObject]()
    var _limit: Int?
    var _offset: Int?
    var _orderBy = [OrderBy]()

    public convenience init(_ tables: Table...){
        self.init(tables)
    }

    public convenience init(_ tables:[Table]){
        let columns = tables.map{$0.sortedColumns}.flatMap{$0}
        self.init(columns)

        tables.forEach(appendFrom)
    }

    public convenience init(_ columns: Column...){
        self.init(columns)
    }

    public init(_ columns: [Column]){
        self.columns = columns
    }

    public func appendFrom<T: FromClause>(obj: T){
        let desc = obj.description
        // this isn't a great algorithim for the speed of things
        // it would be better if we had an ordered set for this.

        if let join = obj as? Join{
            if let table = hasFrom[join.right.description] as? Table{
                for (index, each) in from.enumerate(){
                    if let candidate = each as? Table{
                        if candidate == table {
                            from.removeAtIndex(index)
                            break
                        }
                    }
                }
            }
        }


        if let _ = hasFrom[desc]{
            return
        }

        let target = obj as! AnyObject

        hasFrom[desc] = target
        from.append(target)
    }

    public func selectFrom<T: FromClause>(from: T...) -> Select{
        from.forEach(appendFrom)
        return self
    }

//    public func selectFrom<T: FromClause>(from: [T]...) -> Select{
//        from.map(selectFrom)
//        return self
//    }

    public func selectFrom<T: FromClause>(from: [T]) -> Select{
        from.forEach(appendFrom)
        return self
    }

    public func limit(value: Int) -> Select{
        _limit = value
        return self
    }

    public func offset(value: Int) -> Select{
        _offset = value
        return self
    }

    public func orderBy(value: OrderBy...) -> Select{
        return orderBy(value)
    }

    public func orderBy(value: [OrderBy]) -> Select{
        _orderBy.appendContentsOf(value)
        return self
    }

    public var description: String{
        let names = columns.map{"\($0.table!.label).\($0.label)"}
        let out = names.joinWithSeparator(" ")
        return "<Select: \(out)>"
    }
}