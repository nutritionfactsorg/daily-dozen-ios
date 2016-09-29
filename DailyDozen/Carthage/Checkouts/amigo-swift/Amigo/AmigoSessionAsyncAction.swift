//
//  AmigoSessionAsyncAction.swift
//  Amigo
//
//  Created by Adam Venturella on 1/16/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import Foundation


public class AmigoSessionAsyncAction<T>{

    var action: (() -> T)!
    var queue: dispatch_queue_t!

    public init(action: () -> T, queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
        self.action = action
        self.queue = queue
    }


    public func run(){
        dispatch_async(queue){
            self.action()
        }
    }

    public func then(complete: (T) -> ()){
        dispatch_async(queue){
            let results = self.action()

            dispatch_async(dispatch_get_main_queue()){
                complete(results)
            }
        }
    }
}
