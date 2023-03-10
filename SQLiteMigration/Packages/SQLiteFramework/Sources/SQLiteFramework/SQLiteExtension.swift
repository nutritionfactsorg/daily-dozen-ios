//
//  SQLiteExtension.swift
//  SQLiteFramework
//

import Foundation


public extension Bool  {
    
    /// ANSI C: if (NON_ZERO_EXPRESSION) then { EXECUTE_CODE_BLOCK }
    /// SQLite: Boolean values are stored as integers 0 (false) and 1 (true).
    init(int: Int) {
        if int == 0 {
            self.init(false)
        }
        else {
            self.init(true)
        }
    }
    
    func rawInt() -> Int {
        return (self == false) ? 0 : 1
    }
    
}

public extension String {

    /// Convert SQLite column string to Swift String. "NULL" return nil
    static func fromColumn(string o: Any) -> String? {
        if let s = o as? String {
            if s.caseInsensitiveCompare("NULL") != ComparisonResult.orderedSame {
                return s
            }            
        }
        return nil
    }
    
}
