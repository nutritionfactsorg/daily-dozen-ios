//
//  Fields.swift
//  Amigo
//
//  Created by Adam Venturella on 1/3/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import Foundation

public class UUIDField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .BinaryDataAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }

    public override func serialize(value: AnyObject?) -> AnyObject?{

        guard let string = value as? String,
              let uuid = NSUUID(UUIDString: string) else {
            return nil
        }

        var bytes = [UInt8](count: 16, repeatedValue: 0)
        uuid.getUUIDBytes(&bytes)

        return NSData(bytes: bytes, length: bytes.count)
    }

    /// Deserializes `UUID` Bytes back to their `String` representation
    ///
    /// - Attention:
    ///
    /// Each field is treated as an integer and has its value printed as a
    /// zero-filled hexadecimal digit string with the most significant
    /// digit first.  The hexadecimal values "a" through "f" are output as
    /// lower case characters and are case insensitive on input.
    ///
    /// RFC 4122 specifies output as lower case characters
    /// when NSUUID decodes the bytes back into the string it 
    /// keeps them as upper case. We intentionally force
    /// the values back to lower case to keep in line with the RFC
    ///
    /// - SeeAlso:
    ///
    ///  RFC 4122 (https://www.ietf.org/rfc/rfc4122.txt)
    ///
    ///  Declaration of syntactic structure
    ///
    public override func deserialize(value: AnyObject?) -> AnyObject?{
        guard let value = value as? NSData else {
            return nil
        }

        var bytes = [UInt8](count: 16, repeatedValue: 0)
        value.getBytes(&bytes, length: bytes.count)

        let uuid = NSUUID(UUIDBytes: bytes).UUIDString.lowercaseString
        return uuid
    }
}


public class CharField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .StringAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}


public class BooleanField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .BooleanAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}


public class IntegerField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .Integer64AttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }

    override public func modelValue(model: AmigoModel) -> AnyObject? {
        let value = model.valueForKey(label)

        if let value = value as? Int where value == 0 && primaryKey == true{
            return nil
        }

        return value
    }
}


public class FloatField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .FloatAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}


public class DoubleField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .DoubleAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}


public class BinaryField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .BinaryDataAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}


public class DateTimeField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .DateAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}