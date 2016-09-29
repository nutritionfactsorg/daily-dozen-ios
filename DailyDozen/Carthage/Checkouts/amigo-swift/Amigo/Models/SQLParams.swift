//
//  SQLParams.swift
//  Amigo
//
//  Created by Adam Venturella on 1/13/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import Foundation

public struct SQLParams{
    let queryParams: [AnyObject]
    let defaultValues: [String: AnyObject]
    let automaticPrimaryKey: Bool
}