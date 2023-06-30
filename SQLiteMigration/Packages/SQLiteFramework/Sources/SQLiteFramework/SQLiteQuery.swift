//
//  SQLiteQuery.swift
//  SQLiteFramework
//

import Foundation
import SQLiteCLib

// defines not currently imported to Swift from <sqlite3.h>
//#define SQLITE_STATIC      ((sqlite3_destructor_type)0)
//#define SQLITE_TRANSIENT   ((sqlite3_destructor_type)-1)                 
// SQLITE_STATIC static, unmanaged value. not freed by SQLite.
private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
// SQLITE_TRANSIENT volatile value. SQLite makes private copy before returning.
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

/// SQLiteQuery class manipulates and executes SQL statements.
/// 
/// Supports:
/// 
/// DML (Data Manipulation Language) statements: `SELECT`, `INSERT`, `UPDATE` and `DELETE`
///
/// ```
/// CRUD
/// C (create) INSERT
/// R (read)   SELECT
/// U (update) UPDATE
/// D (delete) DELETE
/// ```
/// 
/// DDL (Data Definition Language) statements: `CREATE TABLE`. 
/// 
/// Successful SQL execution sets the query state to active (true). A new SQL query statement is positioned on an invalid record. An active query must be navigated to a valid record (so that isValid() returns true) before values can be retrieved.
/// 
/// :NYI:???: Is the following true? : If an active query that is a `SELECT` statement exists when you call SQLiteDatabase commit() or rollback(), the commit or rollback will fail. See isActive() for details.
/// 
/// :NYI: SQLiteQuery supports prepared query execution and the binding of parameter values to placeholders. 
/// 
/// Identify placeholders use a colon-name syntax like `:AAA`.
/// 
/// Retrieve the values of all the fields in a single variable (a map) using boundValues().
/// 
/// - Note: unbound parameters retain the original values.
/// 
/// - Important: Open an SQL connection creating a SQLiteQuery. And, keep the connection open while the query exists.
public class SQLiteQuery {
    
    //    enum StatementType { 
    //        case whereStatement
    //        case selectStatement
    //        case updateStatement
    //        case insertStatement
    //        case deleteStatement
    //    }
    
    //   enum BindingSyntax {
    //        case positionalBinding
    //        case namedBinding
    //    }
    
    public let QUERY_NO_ERROR = 0 // :NYI: use something more modern.

    /// Database
    public var _db: SQLiteDatabase // :WIP:ACCESS_LEVEL:INTERNAL:
    /// Original SQL statement
    public var _sql: String // :WIP:ACCESS_LEVEL:INTERNAL:
    /// Bindings where SQL statement ":1" is binding position `1`
    public var _bindings: [Int32] // :WIP:ACCESS_LEVEL:INTERNAL:
    /// :returns: SQLiteResult array of [Str]
    public var _result: SQLiteResult // :WIP:ACCESS_LEVEL:INTERNAL:
    
    /// :WIP:ACCESS_LEVEL:FILEPRIVATE:
    public var _laststatus: SQLiteStatus
    
    /// Prepared statement ID
    public var pStatementId: Int?
    
    public init(db: SQLiteDatabase) {
        // print("•  SQLiteQuery.init()")
        self._db = db
        self._sql = ""
        self._laststatus = SQLiteStatus(
            type: SQLiteStatusType.noError,
            context: "SQLiteQuery init()", 
            dbCode: 0,
            dbMessage: "no error" 
        )
        self._bindings = []
        self._result = SQLiteResult()
    }
    
    /// Construct SQLiteQuery from an SQL query String. 
    /// A non-empty query string will be executed.
    public init(sql: String = "", db: SQLiteDatabase) {
        // print("•  SQLiteQuery.init()")
        
        self._db = db
        self._sql = ""
        self._laststatus = SQLiteStatus(
            type: SQLiteStatusType.noError,
            context: "SQLiteQuery init()", 
            dbCode: 0,
            dbMessage: "no error" 
        )
        self._bindings = []
        self._result = SQLiteResult()
        
        // execute a nonempty SQL statement
        if !sql.isEmpty {
            if statementPrepare(sql) == QUERY_NO_ERROR {
                statementExecute()
            } 
            else {
                print("ERROR: query.statementPrepare sql==\(sql)")
                fatalError()
            }
        }
    }
    
    deinit {
        if let id = pStatementId {
            _db.statementRemove(id)
        }
    }
    
    // MARK: - Query Management
    
    public func statementPrepare(_ sql: String) -> Int {
        var pStatement: OpaquePointer? = nil
        if _db.dbPtr != nil {
            if let cSql = sql.cString(using: String.Encoding.utf8) {
                let statusPrepare = sqlite3_prepare_v2(
                    _db.dbPtr,  // sqlite3 *db          : Database handle
                    cSql,        // const char *zSql     : SQL statement, UTF-8 encoded
                    -1,          // int nByte            : -1 to first zero terminator | zSql max bytes
                    &pStatement, // qlite3_stmt **ppStmt : OUT: Statement byte code handle
                    nil          // const char **pzTail  : OUT: unused zSql pointer
                ) 
                if statusPrepare != SQLITE_OK {
                    setStatusError(context: "statementPrepare", code: statusPrepare)
                }
                else {
                    pStatementId = _db.statementAdd(pStatement!)
                    setStatusOk(context: "statementPrepare")
                }
                return Int(statusPrepare)
            }
        }
        return Int.max
    }
    
    public func statementReset() {
        if let id = pStatementId {
            if let pStatement = _db.statementGet(id) {
                sqlite3_reset(pStatement)
            }
            else {
                setStatusError(context: "statementReset", message: "driver.statementGet(id) is nil")
            }
        }
        else {
            setStatusError(context: "statementReset", message: "pStatementId is nil")
        }
    }
    
    public func statementBind(paramIndex: Int32, paramValue: String) -> Int32 {
        if let id = pStatementId {
            if let pStatement = _db.statementGet(id) {
                if let cParamValue = paramValue.cString(using: String.Encoding.utf8) {
                    let statusBind = sqlite3_bind_text(
                        pStatement,       // sqlite3_stmt*  : statement from sqlite3_prepare_v2()
                        paramIndex,       // int            : parameter index to be set. starts @ 1
                        cParamValue,      // const char*    : parameter value to bind
                        -1,               // int            : -1 for NUL terminated text | value byte count
                        SQLITE_TRANSIENT  // void(*)(void*) : SQLITE_TRANSIENT: SQLite makes private copy
                    )
                    if statusBind != SQLITE_OK {
                        setStatusError(context: "statementBind", code: statusBind)
                    }
                    else {
                        setStatusOk(context: "statementBind")
                    }
                    return statusBind
                }
            }
            else {
                setStatusError(context: "statementBind", message: "driver.statementGet(id) is nil")
            }
        }
        else {
            setStatusError(context: "statementBind", message: "pStatementId is nil")
        } 
        return SQLITE_ERROR // 1
    }
    
    public func statementExecute() {
        if let id = pStatementId {
            let pStatement = _db.statementGet(id)
            guard pStatement != nil else {
                setStatusError(context: "statementExecute", message: "pStatement is nil")
                return
            }
            _result = SQLiteResult()
            // first step
            var statusStep = sqlite3_step(pStatement)
            // save column names
            if statusStep == SQLITE_ROW {
                for i in 0 ..< sqlite3_column_count(pStatement) {
                    let cp = sqlite3_column_name(pStatement, i)
                    let columnName = String(cString: cp!)
                    _result.columnNames.append(columnName)
                }
            }
            while statusStep == SQLITE_ROW {
                var rowData = [Any?]() // [AnyObject?]()
                
                // ROW DATA
                for i in 0 ..< sqlite3_column_count(pStatement) { 
                    // let cp = sqlite3_column_name(pStatement, i)
                    // let columnName = String.fromCString(cp)!
                    
                    switch sqlite3_column_type(pStatement, i) {
                    case SQLITE_BLOB:
                        // print("SQLITE_BLOB:    \(columnName)")
                        fatalError("ERROR: statementExecute() SQLITE_BLOB unsupported")
                    case SQLITE_FLOAT:  
                        let v: Double = sqlite3_column_double(pStatement, i)
                        // :???:SWIFT2: rowData.append(v)
                        // :Ubuntu: error: cannot convert value of type 'Double' to type 'AnyObject?' in coercion
                        //  as AnyObject?
                        rowData.append(v) 
                        // print("SQLITE_FLOAT:   \(columnName)=\(v)")
                    case SQLITE_INTEGER:
                        // let v:Int32 = sqlite3_column_int(pStatement, i)
                        let v: Int = Int(sqlite3_column_int64(pStatement, i)) // Int64
                        // :SWIFT2: rowData.append(v)
                        // :Ubuntu: error: cannot convert value of type 'Int' to type 'AnyObject?' in coercion
                        // as AnyObject? -->
                        // as! AnyObject --> warn, always succeeds
                        // as AnyObject 
                        rowData.append(v) // v as AnyObject?
                        // print("SQLITE_INTEGER: \(columnName)=\(v)")
                    case SQLITE_NULL:  
                        // :?: add null objects?  ... preferrably not. 
                        // print("SQLITE_NULL:    \(columnName)")
                        // thisRow += [nil]
                        rowData.append(nil)
                        break
                    case SQLITE_TEXT: // SQLITE3_TEXT
                        if let v = sqlite3_column_text(pStatement, i) {
                            // :SWIFT2: let s = String(cString: CCharPointer(v))
                            // :SWIFT2: rowData.append(s!)
                            // :Ubuntu: error: cannot convert value of type 'Double' to type 'AnyObject?' in coercion
                            let s = String(cString: v)
                            //  as AnyObject?
                            rowData.append(s) 
                            // print("SQLITE_TEXT:    \(columnName)=\(s!)")
                        } 
                        else {
                            setStatusError(context: "statementExecute", message: "SQLITE_TEXT: not convertable")
                            print("ERROR: statementExecute() SQLITE_TEXT: not convertable")
                            fatalError("ERROR: statementExecute() SQLITE_TEXT: not convertable") // :REMOVE:
                        }            
                    default:
                        setStatusError(context: "statementExecute", message: "sqlite3_column_type not found")
                        print("ERROR: statementExecute() sqlite3_column_type not found")
                        fatalError("ERROR: statementExecute() sqlite3_column_type not found") // :REMOVE:
                        break
                    }
                }          
                
                _result.data.append(rowData) 
                
                // next step
                statusStep = sqlite3_step(pStatement)
            }
            if statusStep != SQLITE_DONE {
                setStatusError(context: "statementExecute", code: statusStep)
            }
            else {
                setStatusOk(context: "statementExecute")
            }
        }
        else {
            setStatusError(context: "statementExecute", message: "pStatementId is nil")
        } 
    }
    
    // MARK: - Results Management
    
    /// - Returns: SQLiteResult result
    public func getResult() -> SQLiteResult? {
        return _result
    }
    
    // :NYI:ADD: other results navigation here.
    
    // MARK: - Status (Error) Management
    
    /// - Returns: SQLiteStatus information
    public func getStatus() -> SQLiteStatus {
        return _laststatus;
    }
    
    /// - Returns: `true` if error occurred.
    public func hasError() -> Bool {
        if _laststatus.type == .noError {
            return false
        }
        return true
    }
    
    public func setStatus(_ status: SQLiteStatus) {
        _laststatus = status
    }
    
    /// :WIP:ACCESS_LEVEL:FILEPRIVATE:
    public func setStatusError(context: String, message: String) {
        let err = SQLiteStatus(
            type: SQLiteStatusType.statementError, 
            context: context, 
            dbCode: Int32.max, 
            dbMessage: message
        )
        setStatus(err)
        print(err.toString())
    }
    
    /// :WIP:ACCESS_LEVEL:FILEPRIVATE:
    public func setStatusError(context: String, code: Int32) {
        if let errmsg = String(validatingUTF8: sqlite3_errmsg(_db.dbPtr)) {
            let err = SQLiteStatus(
                type: SQLiteStatusType.statementError, 
                context: context, 
                dbCode: code, 
                dbMessage: errmsg
            )
            setStatus(err)
            print(err.toString())
        }
        else {
            let err = SQLiteStatus(
                type: SQLiteStatusType.statementError, 
                context: context, 
                dbCode: code, 
                dbMessage: "String.fromCString failed"
            )
            setStatus(err)
            print(err.toString())
        }
    }
    
    /// :WIP:ACCESS_LEVEL:FILEPRIVATE:
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
    
}
