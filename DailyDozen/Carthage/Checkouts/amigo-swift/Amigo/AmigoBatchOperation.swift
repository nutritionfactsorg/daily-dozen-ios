//
//  BatchOperation.swift
//  Amigo
//
//  Created by Adam Venturella on 1/14/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import Foundation

public protocol AmigoBatchOperation{
    init(session: AmigoSession)

    func add<T: AmigoModel>(obj: T)
    func add<T: AmigoModel>(obj: T, upsert: Bool)
    func add<T: AmigoModel>(obj: [T], upsert: Bool)
    func add<T: AmigoModel>(obj: [T])

    func delete<T: AmigoModel>(obj: T)
    func delete<T: AmigoModel>(obj: [T])

    func execute()
}