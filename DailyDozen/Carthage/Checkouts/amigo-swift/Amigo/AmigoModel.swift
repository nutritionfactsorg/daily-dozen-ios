//
//  AmigoModel.swift
//  Amigo
//
//  Created by Adam Venturella on 7/2/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation



@objc
public class AmigoModel: NSObject{
    static var amigoModelIndex = [String: ORMModel]()

    public override init(){
        super.init()
        let _ = amigoModel
    }

    lazy var qualifiedName: String = {
        return self.dynamicType.description()
    }()

    lazy var amigoModel: ORMModel = {
        return AmigoModel.amigoModelIndex[self.qualifiedName]!
    }()
}