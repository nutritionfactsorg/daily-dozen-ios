//
//  SQLiteFramework/SQLiteFramework.swift
//

import Foundation
import SQLiteCLib

public struct SQLite {
    
    // :UNUSED: casting names no longer needed
    /// type for pointer which cannot be represented in Swift
    //typealias sqlite3 = OpaquePointer // :SWIFT2: COpaquePointer
    /// UnsafePointer<UInt8> `const unsigned char *`
    //typealias CCharHandle  = UnsafeMutablePointer<UnsafeMutablePointer<CChar>>
    //typealias CCharPointer = UnsafeMutablePointer<CChar>
    //typealias CVoidPointer = UnsafeMutableRawPointer // :SWIFT2: UnsafeMutablePointer<Void>
    // Int32 CInt
    
    public static func escapeLikeString(_ s: String, escapeChar: String) -> String {
        var strOut = s.replacingOccurrences(of: "_", with: escapeChar + "_")
        strOut = strOut.replacingOccurrences(of: "%", with: escapeChar + "%")
        return strOut
    }

    public static func getProcessInfo() -> [String:String] {        
        return SpmResourcesUtil.getProcessInfo()
    }
    
    public static func getSqliteInfo() -> [String:String] {
        var info: [String:String] = [:]
         // Int32 0 
        // Result (Error) Code https://sqlite.org/rescode.html
        info["SQLITE_OK"] = String(SQLITE_OK)      // Int32 (0) SQLITE_OK
        // Text Encoding https://sqlite.org/c3ref/c_any.html
        info["SQLITE_UTF8"] = String(SQLITE_UTF8)  // Int32 #define SQLITE_UTF8 (1) 
        info["SQLITE_VERSION"] = SQLITE_VERSION    // String "3.21.0"
        info["SQLITE_VERSION_NUMBER"] = String(SQLITE_VERSION_NUMBER) // Int32 3021000
        info["SQLITE_SOURCE_ID"] = SQLITE_SOURCE_ID // String 2017-10-24 18:55:49 1a584e49…
        return info
    }
    
}
