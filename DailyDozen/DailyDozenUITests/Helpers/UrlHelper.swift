//
//  UrlHelper.swift
//  DailyDozenUITests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import XCTest

/// Manages paths base/locale/device/topic_timestamp for screenshots
struct UrlHelper {
    // singleton
    static let shared = UrlHelper()
    // properties
    private let _fm = FileManager.default
    private let _timestamp: String
    private let _urlBase: URL
    private let _urlLocale: URL

    init() {
        print("::INIT:: UITestHelper")
        // Setup test session timestamp 
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        _timestamp = dateFormatter.string(from: now)
        
        // Setup …/Screenshots/ directory
        let environment: [String: String] = ProcessInfo.processInfo.environment

        #if targetEnvironment(simulator)
        guard let path = environment["XCTestBundlePath"] else {
            fatalError("UrlHelper:FAIL: could not find XCTestBundlePath")
        }
        
        let url = URL(fileURLWithPath: path, isDirectory: true)
            .deletingLastPathComponent() // DailyDozenUITests.xctest
            .deletingLastPathComponent() // PlugIns
            .deletingLastPathComponent() // DailyDozenUITests-Runner.app
            .deletingLastPathComponent() // Debug-iphonesimulator
            .deletingLastPathComponent() // Products
            .deletingLastPathComponent() // Build
            .appendingPathComponent("Screenshots", isDirectory: true)
        
        do {
            try _fm.createDirectory(
                at: url, 
                withIntermediateDirectories: true // de facto check for directory existance
            )
            _urlBase = url
            print("\nSCREENSHOTS:\n\(_urlBase.path)")
        } catch {
            fatalError("UrlHelper:FAIL: init /Screenshots/ \(error)")
        }

        // Setup …/Screenshots/LOCALE/ directory
        let locale = Locale.current.identifier
        _urlLocale = _urlBase.appendingPathComponent(
                "\(locale)_\(_timestamp)", 
                isDirectory: true)        
        do {
            try _fm.createDirectory(at: _urlLocale, withIntermediateDirectories: true)
        } catch {
            fatalError("UrlHelper:FAIL: could create /dirLocale/ \(error)")
        }   
        
        // Print info
        print(infoDevice)
        #else
        _urlBase = URL(fileURLWithPath: ":NYI:", isDirectory: true)
        _urlLocale = URL(fileURLWithPath: ":NYI:", isDirectory: true)
        #endif
    }
    
    func dirBase() -> URL {
        return _urlBase
    }
    
    func dirLocale() -> URL {
        return _urlLocale
    }
    
    func dirNamedDevice() -> URL {
        let deviceName = UIDevice.current.name
            //.replacingOccurrences(of: "(", with: "_")
            //.replacingOccurrences(of: "generation", with: "")
            //.replacingOccurrences(of: ")", with: "")
            //.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: " ", with: "_")
        let deviceSystem = UIDevice.current.systemVersion
            .replacingOccurrences(of: ".", with: "_")
        let dirName = "\(deviceName)_v\(deviceSystem)"
        let url = dirLocale()
            .appendingPathComponent(dirName, isDirectory: true)
        
        do {
            try _fm.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            fatalError("UrlHelper:FAIL: could create /dirNamedDevice/ \(error)")
        }
        return url
    }

    func dirTopic(_ topic: String) -> URL {
        let url = dirNamedDevice().appendingPathComponent(topic, isDirectory: true)        
        do {
            try _fm.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            fatalError("UrlHelper:FAIL: /dirTopic/ \(error)")
        }   
        return url
    }
    
    var infoAppLaunchEnvironment: String {
        let currentLocale = Locale.current
        return currentLocale.identifier
    }

    var infoDevice: String {
        let device = UIDevice.current
        //let uiIdiom = device.userInterfaceIdiom // phone, pad, tv, mac
        return """
        DEVICE:
                     model = \(device.model)
                      name = \(device.name)
                systemName = \(device.systemName)
             systemVersion = \(device.systemVersion)
        
        """
    }
        
    var infoLocale: String {
        let currentLocale = Locale.current
        return """
        LOCALE:
          decimalSeparator = \(currentLocale.decimalSeparator ?? "nil")
        
                identifier = \(currentLocale.identifier)
              languageCode = \(currentLocale.languageCode ?? "nil")
                regionCode = \(currentLocale.regionCode ?? "nil")
                scriptCode = \(currentLocale.scriptCode ?? "nil")
               variantCode = \(currentLocale.variantCode ?? "nil")
        
                  calendar = \(currentLocale.calendar)
          usesMetricSystem = \(currentLocale.usesMetricSystem)
        
        """
    }

    var infoLocaleIdentifier: String {
        let currentLocale = Locale.current
        return currentLocale.identifier
    }
    
    var infoProcessArguments: String {
        return "ARGUMENTS:\n\(CommandLine.arguments)\n"
    }

    var infoProcessEnvironment: String {
        return "PROCESS ENVIRONMENT:\n\(ProcessInfo.processInfo.environment)\n"
    }
    
    func writeScreenshot(_ screenshot: XCUIScreenshot, dir: URL, name: String) {
        #if targetEnvironment(simulator)
        let pngData: Data = screenshot.pngRepresentation
        writeScreenshot(data: pngData, dir: dir, name: name)
        #else
        return
        #endif
    }
    
    func writeScreenshot(data: Data, dir: URL, name: String) {
        #if targetEnvironment(simulator)
        let url = dir.appendingPathComponent(name)
        try? data.write(to: url)        
        #else
        return
        #endif
    }

}
