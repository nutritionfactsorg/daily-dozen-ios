//
//  SQLiteStatus.swift
//  SQLiteFramework
//

import Foundation

public enum SQLiteStatusType {
    /// No error occurred
    case noError
    /// Connection (open) error
    case connectionError
    /// SQL statement syntax error
    case statementError    
    /// Transaction failed error
    case transactionError  
    /// Unknown error
    case unknownError      
}

public struct SQLiteStatus {

    public let context: String
    public let dbCode: Int32
    public let dbMessage: String
    public let type: SQLiteStatusType
    // let isValid: Bool

    public init(type: SQLiteStatusType, context: String) {
        self.context = context
        self.dbCode = 0
        self.dbMessage = ""
        self.type = type
    }

    public init(type: SQLiteStatusType, context: String, dbMessage: String) {
        self.context = context
        self.dbCode = 0
        self.dbMessage = dbMessage
        self.type = type
    }

    public init(type: SQLiteStatusType, context: String, dbCode: Int32, dbMessage: String) {
        self.context = context
        self.dbCode = dbCode
        self.dbMessage = dbMessage
        self.type = type
    }

    public func toString() -> String {        
        return "STATUS:\(type):\(context):\(dbCode):\(dbMessage)"
    }
    
    // :NYI: operators == != =

}
