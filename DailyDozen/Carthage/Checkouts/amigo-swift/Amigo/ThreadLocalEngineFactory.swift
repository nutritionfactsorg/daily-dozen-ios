//
//  ThreadLocalEngineFactory.swift
//  Amigo
//
//  Created by Adam Venturella on 7/22/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public protocol ThreadLocalEngineFactory: EngineFactory{
    func createEngine() -> Engine
}

extension ThreadLocalEngineFactory{

    func engineForCurrentThread() -> Engine? {
        let dict = NSThread.currentThread().threadDictionary
        let obj = dict["amigo.threadlocal.engine"] as? Engine

        if let obj = obj{
            return obj
        } else {
            return nil
        }
    }

    func createEngineForCurrentThread() -> Engine {
        let engine = createEngine()
        let dict = NSThread.currentThread().threadDictionary
        dict["amigo.threadlocal.engine"] = engine as? AnyObject

        return engine
    }

    public func connect() -> Engine {
        if let engine = engineForCurrentThread(){
            return engine
        } else {
            return createEngineForCurrentThread()
        }
    }
}
