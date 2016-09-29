//
//  EngineFactory.swift
//  Amigo
//
//  Created by Adam Venturella on 7/22/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public protocol EngineFactory{
    func connect() -> Engine
}