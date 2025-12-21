//
//  LogService.swift
//  DailyDozen
//
//  Copyright © 2020-2025 NutritionFacts.org. All rights reserved.
//

import Foundation

let logit = LogService.shared

///
/// - Note: Be sure to set the "DEBUG" symbol in the compiler flags
///   for the development build.
///
/// `Build Settings` > `All, Levels` > `Swift Compiler` - `Custom Flags/Other Swift Flags` >
/// `(+) -D DEBUG`
public enum LogServiceLevel: Int, Comparable {
    case all        = 6 // highest verbosity
    case verbose    = 5 // e.g. trace
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
        }
    }
    
    // Set the "DEBUG" symbol in the compiler flags
#if DEBUG
    static nonisolated(unsafe) public let defaultLevel = LogServiceLevel.all
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

actor LogService {
    static let shared = LogService()
    
    /// Current log level.
    public var logLevel = LogServiceLevel.defaultLevel
    
    /// Log line counter
    private var lineCount = 0
    /// Log line numbers to watch: [Int]
    public var watchpointList: [Int] = []
    
    /// DateFromatter used internally.
    private let dateFormatter = DateFormatter()
    
    public init() {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 24H
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss.SSS"
    }
    
    // public func message
    public func verbose(_ s: String) {
        if .verbose <= logLevel {
            log(s)
        }
    }
    
    public func debug(_ s: String) {
        if .debug <= logLevel {
            log(s)
        }
    }
    
    public func info(_ s: String) {
        if .info <= logLevel {
            log(s)
        }
    }
    
    public func warning(_ s: String) {
        if .warning <= logLevel {
            log(s)
        }
    }
    
    public func error(_ s: String) {
        if .error <= logLevel {
            log(s)
        }
    }
    
    private func log(_ string: String) {
        lineCount += 1
        var logString = "[[\(lineCount)]] \(string)"
#if DEBUG
        if watchpointList.contains(lineCount) {
            logString = ":::WATCHPOINT::: [[\(lineCount)]]\n" + logString
        }
#endif
        print(logString)
    }
    
}
