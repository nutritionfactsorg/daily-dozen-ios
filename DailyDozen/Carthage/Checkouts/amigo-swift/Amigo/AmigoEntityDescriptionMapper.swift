//
//  AmigoEntityDescriptionMapper.swift
//  Amigo
//
//  Created by Adam Venturella on 7/21/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData

public protocol AmigoEntityDescriptionMapper: Mapper{
    func map(entity: NSEntityDescription) -> ORMModel
}
