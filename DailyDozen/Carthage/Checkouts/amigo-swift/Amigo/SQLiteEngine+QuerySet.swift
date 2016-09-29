//
//  SQLiteEngine+QuerySet.swift
//  Amigo
//
//  Created by Adam Venturella on 7/24/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import FMDB

extension SQLiteEngine{
    public func execute<T: AmigoModel>(queryset:QuerySet<T>) -> [T]{
        let select = queryset.compile()
        let sql = compiler.compile(select)
        let model = queryset.model
        let models = queryset.config.tableIndex
        let mapper = queryset.mapper
        var result = [T]()

        var objectMap = [ORMModel: String]()
        var params: [AnyObject]!

        if let predicateParams = select.predicateParams{
            params = predicateParams
        }

        if select.from.count > 1{
            model.foreignKeys.forEach{ (key, value)-> () in
                let ormModel = models[value.foreignKey!.relatedTable.label]!
                objectMap[ormModel] = key
            }
        }

        let modelMapper = { (results: FMResultSet) -> [T] in

            var rows = [T]()

            while results.next(){
                var objs = [ORMModel: AmigoModel]()
                var currentModel = model

                objs[currentModel] = mapper.instanceFromString(model.type)

                select.columns.forEach{
                    var active: AmigoModel!
                    currentModel = models[$0.table!.label]!

                    if let obj = objs[currentModel]{
                        active = obj
                    } else {
                        let root = objs[model]!
                        let key = objectMap[currentModel]!
                        active = mapper.instanceFromString(currentModel.type)
                        objs[currentModel] = active
                        root.setValue(active, forKey: key)
                    }

                    let value = results.objectForColumnName($0.qualifiedLabel!)
                    active.setValue($0.deserialize(value), forKey: $0.label)
                }

                rows.append(objs[model]! as! T)
            }

            results.close()
            return rows
        }

        result = execute(sql, params: params){ (results: FMResultSet) -> [T] in
            return modelMapper(results)
        }
        
        return result
    }
}