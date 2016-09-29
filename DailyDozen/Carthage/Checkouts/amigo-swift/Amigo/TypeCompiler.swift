//
//  TypeCompiler.swift
//  Amigo
//
//  Created by Adam Venturella on 7/7/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData

public protocol TypeCompiler{
    func process(type: NSAttributeType) -> String
    func compileInteger16() -> String
    func compileInteger32() -> String
    func compileInteger64() -> String
    func compileString() -> String
    func compileBoolean() -> String
    func compileDate() -> String
    func compileBinaryData() -> String
    func compileDecimal() -> String
    func compileDouble() -> String
    func compileFloat() -> String
    func compileUndefined() -> String
}


extension TypeCompiler{
    public func process(type: NSAttributeType) -> String {
        switch type{
        case .Integer16AttributeType:
            return compileInteger16()
        case .Integer32AttributeType:
            return compileInteger32()
        case .Integer64AttributeType:
            return compileInteger64()
        case .StringAttributeType:
            return compileString()
        case .BooleanAttributeType:
            return compileBoolean()
        case .DateAttributeType:
            return compileDate()
        case .BinaryDataAttributeType:
            return compileBinaryData()
        case .DecimalAttributeType:
            return compileDecimal()
        case .DoubleAttributeType:
            return compileDouble()
        case .FloatAttributeType:
            return compileFloat()
        case .UndefinedAttributeType:
            return compileUndefined()
        default:
            // NSAttributeType.TransformableAttributeType
            // NSAttributeType.ObjectIDAttributeType
            return compileUndefined()
        }
    }
}