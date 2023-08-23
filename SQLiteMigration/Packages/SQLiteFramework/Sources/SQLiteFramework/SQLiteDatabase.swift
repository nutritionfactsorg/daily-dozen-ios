//
//  SQLiteDatabase.swift
//  SQLiteFramework
//
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable file_length
// swiftlint:disable identifier_name
// swiftlint:disable type_body_length

import Foundation
import SQLiteCLib

/// `class SQLiteDatabase` represents a specific database.
/// 
/// Once a database is open:
///  
/// * `tables()` list of tables in the database, 
/// * `primaryIndex()` to get a table's primary index
/// * `record()` to get meta-information about a table's fields (e.g., field names).
/// * `getStatus()` information about last status update.
///  
/// **Note:** 
/// Use SQLiteQuery executeStatement() to execute a prepared query statement.
///  
/// :NYI: Use transaction() to start a transaction.
/// Use commit() or rollback() to complete a transaction. 
/// When using transactions, start the transaction before creating the query.
/// SQLite supports BindName and BindPosition
/// 
/// :NYI: SQLiteDatabase.getConnectionUri
/// --> https://sqlite.org/c3ref/db_filename.html
/// 
/// :NYI: SQLiteDatabase.getStatus 
/// --> https://sqlite.org/c3ref/status.html     // SQLite Runtime Status
/// --> https://sqlite.org/c3ref/db_status.html  // Database Connection Status
/// 
/// :NYI: SQLiteDatabase.getVersion
/// --> https://sqlite.org/c3ref/libversion.html
public class SQLiteDatabase {
    
    public enum ConnectionOption {
        // SQLite Options
        /// int milliseconds https://sqlite.org/c3ref/busy_timeout.html
        case sqlite_BUSY_TIMEOUT 
        case sqlite_OPEN_READONLY
        case sqlite_OPEN_URI
        // case SQLITE_ENABLE_SHARED_CACHE
        // sqlite3_enable_shared_cache unavalaible in Swift. deprecated in OSX 10.9
    }
    public typealias OptionDictionary = [ConnectionOption: AnyObject]
    
    // :WIP:ACCESS_LEVEL.FILEPRIVATE
    public var _laststatus: SQLiteStatus = SQLiteStatus(
        type: SQLiteStatusType.noError, 
        context: "Initial Status"
    )  
    
    // SQLite 
    public var dbOptions: OptionDictionary
    public var dbUrl: URL
    public var dbPtr: OpaquePointer? // sqlite3 *db : Database handle
    public var stmtDictionary = [Int: OpaquePointer]()
    public var stmtIdCount = 0
    
    /// :NYI: throws 
    public init(url: URL, options: OptionDictionary = [:]) {
        self.dbUrl = url
        self.dbOptions = options
    }
    
    deinit {
    }
    
    ///  
    ///  - Parameter dbname: database file pathname 
    ///  - Parameter options:  SQLITE_BUSY_TIMEOUT, SQLITE_OPEN_READONLY, SQLITE_OPEN_URI
    ///  
    ///  - Returns: `true` if successful. 
    /// 
    public func open() -> Bool {
        let timeOut: Int32 = 
            dbOptions[ConnectionOption.sqlite_BUSY_TIMEOUT] as? Int32 ?? 5000
        
        let openReadOnlyOption: Bool = 
            dbOptions[ConnectionOption.sqlite_OPEN_READONLY] as? Bool ?? false
        
        let openUriOption: Bool =
            dbOptions[ConnectionOption.sqlite_OPEN_URI] as? Bool ?? false
        
        if isOpen() {
            let closedOk: Bool = close()
            if !closedOk {
                // :NYI: add error message to log
            }
        }
        
        var openMode: Int32 = openReadOnlyOption ? SQLITE_OPEN_READONLY : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE)
        if openUriOption {
            openMode |= SQLITE_OPEN_URI
        }
        
        if let cFileName = dbUrl.path.cString(using: String.Encoding.utf8) {
            let status = sqlite3_open_v2(
                cFileName, // filename: UnsafePointer<CChar> 
                &dbPtr,      // ppDb: UnsafeMutablePointer<COpaquePointer> aka handle
                openMode,  // flags: Int32 
                nil        // zVfs: UnsafePointer<Int8>
            )
            if status == SQLITE_OK && dbPtr != nil {
                // sqlite3_busy_timeout(database: COpaquePointer, ms: Int32)
                sqlite3_busy_timeout(dbPtr, timeOut)
                setStatusOk(context: "open success")
                return true
            } else {
                if dbPtr != nil {
                    sqlite3_close_v2(dbPtr)
                    dbPtr = nil
                }
                setStatusError(context: "open", code: status)
                return false
            }
        } else {
            setStatusError(context: "ERROR/access open create cString failed")
            return false
        }
    }

    
    /// Releases all query statements, then closes the database.
    /// - Returns: `true` if successful.
    public func close() -> Bool {
        if isOpen() {
            
            for pStatement in stmtDictionary.values {
                sqlite3_finalize(pStatement)
            }
            stmtDictionary = [:]
            
            let status: Int32 = sqlite3_close(self.dbPtr)
            if status != SQLITE_OK {
                setStatusError(context: "FAIL/close", code: status)
            }
            
            dbPtr = nil

            setStatusOk(context: "SUCCESS/close")
            return true
        }
        return true // 
    }

    ///   - Returns: `true` if the database is open.
    public func isOpen() -> Bool {
        return dbPtr != nil ? true : false 
    }
    
    // //////////////////////////
    // MARK: - Import SQL File
    // //////////////////////////
    
    /// importSqlFile executes one line at a time with limitations on allowed file content.
    ///
    /// **Limitations**
    ///
    /// * SQL commands must be terminated by ';'
    /// * Multiple SQL commands on the same line is not supported.
    /// * `--` Line comments must not contain any single quotes.
    /// * Block comments cannot nest. 
    /// * Inline block comments are not supported.
    ///
    public func importSqlFile(url: URL, verbose: Bool = false) {
        guard var fileContent = try? String(contentsOf: url, encoding: String.Encoding.utf8)
            else {return}
        
        // prepare file statements
        fileContent = SQLiteDatabase.removingBlockComments(sql: fileContent)
        fileContent = SQLiteDatabase.removingLineComments(sql: fileContent)
        fileContent = fileContent.appending("\n") // ensure ";\n" pattern for last command line
        
        let lines: [String] = fileContent.components(separatedBy: ";\n")
        var commands = [String]()
        for var l: String in lines {
            l = l.replacingOccurrences(of: "\n", with: " ")
            l = l.trimmingCharacters(in: CharacterSet.whitespaces)
            
            if l.isEmpty == false {
                // restore command line terminator
                l = l.appending(";")
                commands.append( l )
            }
        }
        
        if verbose {
            print("--- SQL from file: ---\n\(url.path)")
            for c in commands {
                print("---\n\(c)")
            }
        }
        
        // execute statements
        for sql in commands {
            let s = String(sql).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if s.count > 0 {
                _ = SQLiteQuery(sql: s, db: self)
            }
        }
    }
    
    /// - Important: Block comments cannot nest. Inline block comments are not supported. 
    /// - Parameters:
    ///     - sql: SQL String
    public static func removingBlockComments(sql: String) -> String {
        var result: String = ""
        var charWas: Character?
        var isInsideDelimiter = false
        var hasPrecedingWhiteSpace = true
        
        for charIs in sql {
            if charWas == nil {
                charWas = charIs
            } else if charWas == "/" && charIs == "*" && hasPrecedingWhiteSpace {
                isInsideDelimiter = true
                charWas = nil
            } else if charWas == "*" && charIs == "/" && isInsideDelimiter {
                isInsideDelimiter = false
                charWas = nil
            } else if !isInsideDelimiter, let cw = charWas {
                if cw == "\n"{
                    hasPrecedingWhiteSpace = true
                } else if cw != " " && cw != "\t" {
                    hasPrecedingWhiteSpace = false
                }
                result.append(cw)
                charWas = charIs
            } else if isInsideDelimiter {
                charWas = charIs
            }
        }
        
        if isInsideDelimiter == false, let cw = charWas {
            result.append(cw)
        }
        
        return result
    }
    
    /// - Note: Supports escaped single quote (`''`)
    /// - Parameters:
    ///     - sql: SQL String
    public static func removingLineComments(sql: String) -> String {
        let lines = sql.split(separator: "\n")
        var result: String = ""
        
        for l: String.SubSequence in lines {
            var lineResult: String = ""
            var charWas: Character?
            var delimiterFound = false
            var inQuote = false
            var isEscaped = false
            
            for charIs: Character in l {
                if charWas == nil {
                    charWas = charIs
                } else if !inQuote && charWas == "'" {
                    inQuote = true
                    if let cw = charWas {
                        lineResult.append(cw)
                        charWas = charIs
                    }
                } else if inQuote {
                    if charWas == "'" && isEscaped {
                        isEscaped = false
                    } else if charWas == "'" && !isEscaped && charIs == "'" {
                        isEscaped = true
                    } else if charWas == "'" && !isEscaped && charIs != "'" {
                        inQuote = false
                    }
  
                    if let cw = charWas {
                        lineResult.append(cw)
                        charWas = charIs
                    }
                } else if !inQuote && charWas == "-" && charIs == "-" {
                    delimiterFound = true
                    break
                } else if let cw = charWas {
                    lineResult.append(cw)
                    charWas = charIs
                }
            }
            if delimiterFound == false {
                if let cw = charWas {
                    lineResult.append(cw)   
                }
            }
            
            lineResult.append("\n")
            result.append(lineResult)
        }
        if result.suffix(1) == "\n" {
            result = String(result.dropLast())
        }
        return result
    }
    
    ////////////////////////////////////////
    // MARK: - Status (Error) Management
    ////////////////////////////////////////
    
    ///  Error information can be retrieved with `getStatus()`. 
    ///
    ///  - Returns: `true` if error occurred opening the database. 
    public func hasError() -> Bool {
        if _laststatus.type == .noError {
            return false
        }
        return true
    }
    
    // MARK: - Query Statements
    
    public func statementAdd(_ stmt: OpaquePointer) -> Int {
        stmtIdCount += 1
        stmtDictionary[stmtIdCount] = stmt
        return stmtIdCount
    }
    
    public func statementGet(_ id: Int) -> OpaquePointer? {
        if let pStatement = stmtDictionary[id] {
            return pStatement
        } else {
            return nil
        }
    }
    
    /// finalize and remove statement
    public func statementRemove(_ id: Int) {
        if let pStatement = stmtDictionary[id] {
            sqlite3_finalize(pStatement)
            stmtDictionary.removeValue(forKey: id)
        }
    }
    
    public func setStatus(_ status: SQLiteStatus) {
        _laststatus = status
    }
    
    /// Returns status information about database action.
    /// 
    /// :NYI: Failures that occur in conjunction with an individual query are
    ///  reported by SQLiteQuery.getStatus().
    ///  
    ///  - Returns: SQLiteStatus information
    /// 
    public func getStatus() -> SQLiteStatus {
        return _laststatus
    }
    
    // :WIP:ACCESS_LEVEL.FILEPRIVATE
    public func setStatusError(context: String) {
        let err = SQLiteStatus(
            type: SQLiteStatusType.connectionError, 
            context: context, 
            dbCode: Int32.max, 
            dbMessage: "String.fromCString failed"
        )
        setStatus(err)
        print(err.toString())
    }
    
    // :WIP:ACCESS_LEVEL.FILEPRIVATE
    public func setStatusError(context: String, code: Int32) {
        if let errmsg = String(validatingUTF8: sqlite3_errmsg(self.dbPtr)) {
            let err = SQLiteStatus(
                type: SQLiteStatusType.connectionError, 
                context: context, 
                dbCode: code, 
                dbMessage: errmsg
            )
            setStatus(err)
            print(err.toString())
        } else {
            let err = SQLiteStatus(
                type: SQLiteStatusType.connectionError, 
                context: context, 
                dbCode: code, 
                dbMessage: "String.fromCString failed"
            )
            setStatus(err)
            print(err.toString())
        }
    }
    
    // :WIP:ACCESS_LEVEL.FILEPRIVATE
    public func setStatusOk(context: String) {
        let ok = SQLiteStatus(
            type: SQLiteStatusType.noError, 
            context: context, 
            dbCode: SQLITE_OK, 
            dbMessage: "SUCCESS"
        )
        setStatus(ok)
        // print(ok.toString())
    }

    // MARK: - Foreign Keys
    
    public func foreignkeys(_ state: Bool) {
        let s = "PRAGMA foreign_keys = \(state.rawInt());"
        let query = SQLiteQuery(sql: s, db: self)
        if query.getResult() != nil {
            setStatusOk(context: "foreignkeys set = (\(state.rawInt()))")
            return
        }
        setStatusError(context: "FAIL/foreignkeys(\(state.rawInt())) set state")
        return
    }
    
    // returns whether or not foreign keys are enabled.
    public func foreignkeys() -> Bool? {
        let s = "PRAGMA foreign_keys;"
        let query = SQLiteQuery(sql: s, db: self)
        if let result = query.getResult() {
            // result.columnNames = ["foreign_keys"]
            // result.data = [[Optional(0)]]
            if let a = result.data.first,
                let b = a.first, 
                let c = b as? Int {
                let state = Bool(int: c)
                setStatusOk(context: "foreignkeys query ok (\(state.rawInt()))")
                return state
            }
        }
        setStatusError(context: "FAIL/foreignkeys query")
        return nil
    }
    
}
