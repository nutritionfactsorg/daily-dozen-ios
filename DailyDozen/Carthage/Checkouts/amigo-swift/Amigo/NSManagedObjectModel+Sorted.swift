//
//  NSManagedObject+Sorted.swift
//  Amigo
//
//  Created by Adam Venturella on 7/14/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData

//extension NSEntityDescription{
//    public override var description: String{
//        return self.name!
//    }
//}

extension NSManagedObjectModel{

    public func sortedEntities() -> [NSEntityDescription] {
        let list = buildDependencyList()
        return topologicalSort(list)
    }

    func validateTopologicalSort(graph: [NSEntityDescription:[NSEntityDescription]]) -> Bool {
        for (key, value) in graph {
            if value.count > 0 {
                fatalError("Dependency Cycle for Entity: \(key)")
            }
        }

        return true
    }

    public func topologicalSort(dependencyList:[NSEntityDescription:[NSEntityDescription]]) -> [NSEntityDescription]{
        // https://gist.github.com/mrecachinas/0704e8110983fff94ae9

        var sorted = [NSEntityDescription]()
        var next_depth = [NSEntityDescription]()
        var graph = dependencyList

        for key in graph.keys {
            if graph[key]! == [] {
                next_depth.append(key)
            }
        }

        for key in next_depth {
            graph.removeValueForKey(key)
        }

        while next_depth.count != 0 {

            next_depth = next_depth.sort{ $0.name! > $1.name }

            let node = next_depth.removeLast()
            sorted.append(node)

            for key in graph.keys {
                let arr = graph[key]
                let dl = arr!.filter{ $0 == node}
                if dl.count > 0 {
                    graph[key] = graph[key]?.filter({$0 != node})
                    if graph[key]?.count == 0 {
                        next_depth.append(key)
                    }
                }
            }
        }

        validateTopologicalSort(graph)
        return sorted
    }

    public func buildDependencyList() -> [NSEntityDescription:[NSEntityDescription]]{
        var dependencies = [NSEntityDescription:[NSEntityDescription]]()

        // initialize the list
        for each in entities{
            dependencies[each] = []
        }

        for each in entities{
            for (_, relationship) in each.relationshipsByName {

                if relationship.toMany == false{
                    dependencies[each]!.append(relationship.destinationEntity!)
                }
            }
        }

        return dependencies
    }

    public func buildDependencyListStrings() -> [String:[String]]{
        var dependencies = [String:[String]]()

        // initialize the list
        for each in entities{
            dependencies[each.name!] = []
        }

        for each in entities{
            for (_, relationship) in each.relationshipsByName {

                if relationship.toMany == false{
                    dependencies[each.name!]!.append(relationship.destinationEntity!.name!)
                }
            }
        }

        return dependencies
    }
}