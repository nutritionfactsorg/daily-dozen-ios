//
//  LogService.swift
//  LogService
//

import Foundation

///
/// - Note: Be sure to set the "DEBUG" symbol in the compiler flags for the development build.
/// 
/// `Build Settings` > `All, Levels` > `Swift Compiler` - `Custom Flags/Other Swift Flags` >  
/// `(+) -D DEBUG`
public enum LogServiceLevel: Int, Comparable {
    case all        = 6 // highest verbosity
    case verbose    = 5
    case debug      = 4
    case info       = 3
    case warning    = 2
    case error      = 1
    case off        = 0
    
    /// Get string description for log level.
    /// 
    /// - parameter logLevel: A LogLevel
    /// 
    /// - returns: A string.
    public static func description(logLevel: LogServiceLevel) -> String {
        switch logLevel {
        case .all:     return "all"
        case .verbose: return "verbose"
        case .debug:   return "debug"
        case .info:    return "info"
        case .warning: return "warning"
        case .error:   return "error"
        case .off:     return "off"
        // default: assertionFailure("Invalid level")
        // return "Null"
        }
    }
    
    // Set the "DEBUG" symbol in the compiler flags
    #if DEBUG
    static public let defaultLevel = LogServiceLevel.all
    #else
    static public let defaultLevel = LogServiceLevel.warning
    #endif
}

public func < (lhs: LogServiceLevel, rhs: LogServiceLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

public func == (lhs: LogServiceLevel, rhs: LogServiceLevel) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

public struct LogService {
    public private(set) var text = "LogService"
    
    public static var shared = LogService()
    
    /// Current log level.
    public var logLevel = LogServiceLevel.defaultLevel
    
    /// Log line counter
    private var lineCount = 0
    /// Log line numbers to watch: [Int]  
    public var watchpointList: [Int] = []
    ///
    private var logfileUrl: URL?
    
    /// DateFromatter used internally.
    private let dateFormatter = DateFormatter()
    
    public init() {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 24H
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss.SSS"
        
        /// LogFunction used, `print` for DEBUG, file for Production.
        #if DEBUG
            
        #else
            // :NYI: production would use the default file
        #endif
    }
    
    // public func message
    public mutating func verbose(_ s: String) {
        if .verbose <= logLevel {
            log(s)
        }
    }
    
    public mutating func debug(_ s: String) {
        if .debug <= logLevel {
            log(s)
        }
    }
    
    public mutating func info(_ s: String) {
        if .info <= logLevel {
            log(s)
        }
    }
    
    public mutating func warning(_ s: String) {
        if .warning <= logLevel {
            log(s)
        }
    }
    
    public mutating func error(_ s: String) {
        if .error <= logLevel {
            log(s)
        }
    }
    
    private mutating func log(_ string: String) {
        lineCount += 1
        var logString = "[[\(lineCount)]] \(string)"
        #if DEBUG
        if watchpointList.contains(lineCount) {
            logString = "•WATCHPOINT• [[\(lineCount)]]\n" + logString
        }
        #endif
        
        if let url = logfileUrl {
            do {
                let fileHandle = try FileHandle(forWritingTo: url)
                fileHandle.seekToEndOfFile()
                if let data = (logString + "\n").data(using: .utf8) {
                    fileHandle.write( data )
                }
                fileHandle.closeFile()
                #if DEBUG
                    print(logString)
                #endif
            } catch {
                #if DEBUG
                    print("FAIL: could not append to \(url.absoluteString)")
                    print(logString)
                #endif
            }
        } else {
            print(logString)
        }
    }
    
    public mutating func useLogFileDefault() {
        useLogFile(nameToken: "shared")
    }
    
    /// - parameter nameToken: string included in file name
    public mutating func useLogFile(nameToken: String) {
        let currentTime = currentDatetime()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        // formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let dateTimestamp = formatter.string(from: currentTime)
        
        let logfileName = "\(dateTimestamp)_log_\(nameToken).txt"
        
        //  URL.documentsDirectory #available(iOS 16.0, *) #available(macOS 13.0, *)
        let fm = FileManager.default
        let urlList = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDir = urlList[0]
        logfileUrl = documentsDir.appendingPathComponent(logfileName, isDirectory: false)
        
        do {
            if let url = logfileUrl {
                try "FILE: \(logfileName)\n".write(to: url, atomically: true, encoding: String.Encoding.utf8)
            } else {
                print("FAIL: LogService useLogFile() logfileUrl is nil")
            }
        } catch {
            print("FAIL: LogService useLogFile() could not write initial line to \(logfileName)")
        }
    }
    
    // MARK: - Date Manager
    
    /// return "now" date and time
    func currentDatetime() -> Date {
        var datetime = Date()
        #if DEBUG
        var components = DateComponents()
        components.day = 0
        if let d = Calendar.current.date(byAdding: components, to: datetime) {
            datetime = d
        } else {
            LogService.shared.error("DateManager currentDatetime() failed to ")
        }
        #endif
        return datetime
    }
    
}
