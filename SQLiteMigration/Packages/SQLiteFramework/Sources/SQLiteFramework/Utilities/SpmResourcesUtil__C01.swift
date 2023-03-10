//
//  SpmResourcesUtil.swift
//

import Foundation

public class SpmResourcesUtil {
    
    ////////////////
    // MARK: - Linux
    ////////////////
    #if os(Linux)
    
    // Bundle is not yet implemented on Linux
    // Get path to executable via /proc/self/exe
    // https://unix.stackexchange.com/questions/333225/which-process-is-proc-self-for
    
    // Finding: :TBD:
    // 1. ProcessInfo.processInfo.environment "PWD": ".../SQLiteFramework"
    //    is package directory where the `swift` command is executed.
    // 2. SQLiteFramework/.build/x86_64-unknown-linux/debug/SQLiteFrameworkPackageTests.xctest
    //    is an executable
    // 3. SQLiteFramework/.build/x86_64-unknown-linux/debug is the default read/write directory
    public static func getProcessInfo() -> [String:String] {
        var info: [String:String] = [:]
        info["OS"]="Ubuntu"
        info["/proc/self/exe"] = URL(fileURLWithPath: "/proc/self/exe").path
        
        // FileManager
        info["FileManagerCurrentDirectoryPath"] = FileManager.default.currentDirectoryPath
        
        // ProcessInfo Enviroment
        print("## CLI arguments = \(CommandLine.arguments)")
        print("## Process arguments = \(ProcessInfo.processInfo.arguments)")
        print("## Process environment = \(ProcessInfo.processInfo.environment)")
        print("## Process processName = \(ProcessInfo.processInfo.processName)")
        if let pwd = ProcessInfo.processInfo.environment["PWD"] {
            info["ProcessInfoPwd"] = pwd
        }
        
        return info
    }
    
    // /PATH_TO_PACKAGE/PackageName/.build/TestResources
    public static func getTestResourcesUrl() -> URL? {
        guard let packagePath = ProcessInfo.processInfo.environment["PWD"]
            else { return nil }
        let packageUrl = URL(fileURLWithPath: packagePath)
        let testResourcesUrl = packageUrl
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent("TestResources", isDirectory: true)
        return testResourcesUrl
    }
    
    // /PATH_TO_PACKAGE/PackageName/.build/TestScratch
    public static func getTestScratchUrl() -> URL? {
        guard let packagePath = ProcessInfo.processInfo.environment["PWD"]
            else { return nil }
        let packageUrl = URL(fileURLWithPath: packagePath)
        let testScratchUrl = packageUrl
            .appendingPathComponent(".build")
            .appendingPathComponent("TestScratch")
        return testScratchUrl
    }
    
    // /PATH_TO_PACKAGE/PackageName/.build/TestScratch
    public static func resetTestScratch() throws {
        if let testScratchUrl = getTestScratchUrl() {
            let fm = FileManager.default
            do {_ = try fm.removeItem(at: testScratchUrl)} catch {}
            _ = try fm.createDirectory(at: testScratchUrl, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - macOS
    #elseif os(macOS)
    
    // Finding:
    // 1. Use test Bundle for macOS Xcode & macOS CLI for working path.
    // …/DerivedData/SQLiteFramework-…/Build/Products/Debug/SQLiteFrameworkTests.xctest
    // …/SQLiteFramework/.build/x86_64-apple-…/debug/SQLiteFrameworkPackageTests.xctest
    // 2. currentDirectoryPath for TestResource would be OK for macOS CLI, but not macOS Xcode
    // 3. macOS Xcode has no intrinsically available approach to determine the package root path
    public static func getProcessInfo() -> [String:String] {
        var info: [String:String] = [:]
        info["OS"]="macOS"
        
        // FileManager
        info["FileManagerCurrentDirectoryPath"] = FileManager.default.currentDirectoryPath
        // macOS CLI   : …/SQLiteFramework  (Swift Package Root)
        // macOS Xcode : /private/tmp
        
        // ProcessInfo Arguments
        info["Argument0"] = ProcessInfo.processInfo.arguments[0]
        
        // macOS CLI   [0]: …/Xcode.app/Contents/Developer/usr/bin/xctest
        // macOS Xcode [0]: …/Xcode.app/…/Library/Xcode/Agents/xctest
        
        // macOS CLI [1]: …/SQLiteFramework/.build/x86_64-apple-macosx10.10/debug/SQLiteFrameworkPackageTests.xctest"]
        
        // ProcessInfo Enviroment
        print("## CLI arguments = \(CommandLine.arguments)")
        print("## Process arguments = \(ProcessInfo.processInfo.arguments)")
        print("## Process environment = \(ProcessInfo.processInfo.environment)")
        print("## Process processName = \(ProcessInfo.processInfo.processName)")
        if let pwd = ProcessInfo.processInfo.environment["PWD"] {
            info["ProcessInfoPwd"] = pwd
        }
        
        // macOS CLI   PWD: …/SQLiteFramework (Swift Package Root)
        // macOS Xcode PWD: /tmp
        
        // macOS CLI SDKROOT: …/Xcode.app/…/SDKs/MacOSX10.13.sdk
        // macOS CLI LIBRARY_PATH: /usr/local/lib
        // macOS CLI CPATH:        /usr/local/include
        
        // macOS Xcode __XCODE_BUILT_PRODUCTS_DIR_PATHS: …/DerivedData/SQLiteFramework-…/Build/Products/Debug
        // macOS Xcode __XPC_DYLD_FRAMEWORK_PATH: …/DerivedData/SQLiteFramework-…/Build/Products/Debug", …
        // macOS Xcode DYLD_FRAMEWORK_PATH: …/DerivedData/SQLiteFramework-…/Build/Products/Debug: … more
        // macOS Xcode DYLD_LIBRARY_PATH: …/DerivedData/SQLiteFramework-…/Build/Products/Debug: … more
        
        
        // Bundle
        var i = 0
        for bundle in Bundle.allBundles {
            info["Bundle[\(i)]"] = bundle.bundlePath
            i = i + 1
        }
        // macOS Xcode: …/DerivedData/SQLiteFramework-…/Build/Products/Debug/SQLiteFrameworkTests.xctest
        
        return info
    }
    
    public static func getTestBundle() -> Bundle? {
        for bundle in Bundle.allBundles {
            if bundle.bundleURL.pathExtension == "xctest" {
                return bundle
            }
        }
        return nil
    }
    
    public static func isXcodeTestEnvironment() -> Bool {
        let arg0 = ProcessInfo.processInfo.arguments[0]
        // Use arg0.hasSuffix("/usr/bin/xctest") for command line environment
        return arg0.hasSuffix("/Xcode/Agents/xctest")
    }
    
    // /PATH_TO/PackageName/TestResources
    public static func getTestResourcesUrl() -> URL? {
        guard let testBundle = getTestBundle() else {return nil}
        let testBundleUrl = testBundle.bundleURL
        
        if isXcodeTestEnvironment() { // test via Xcode
            let testResourcesUrl = testBundleUrl
                .appendingPathComponent("Contents", isDirectory: true)
                .appendingPathComponent("Resources", isDirectory: true)
                .appendingPathComponent("TestResources", isDirectory: true)
            return testResourcesUrl
        }
        else { // test via command line
            guard let packagePath = ProcessInfo.processInfo.environment["PWD"]
                else { return nil }
            let packageUrl = URL(fileURLWithPath: packagePath)
            let testResourcesUrl = packageUrl
                .appendingPathComponent(".build", isDirectory: true)
                .appendingPathComponent("TestResources", isDirectory: true)
            return testResourcesUrl
        }
    }
    
    public static func getTestScratchUrl() -> URL? {
        guard let testBundle = getTestBundle() else {return nil}
        let testBundleUrl = testBundle.bundleURL
        if isXcodeTestEnvironment() {
            return testBundleUrl
                .deletingLastPathComponent()
                .appendingPathComponent("TestScratch")
        }
        else {
            return testBundleUrl
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("TestScratch")
        }
    }
    
    public static func resetTestScratch() throws {
        if let testScratchUrl = getTestScratchUrl() {
            let fm = FileManager.default
            do {_ = try fm.removeItem(at: testScratchUrl)} catch {}
            _ = try fm.createDirectory(at: testScratchUrl, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - iOS
    
    #elseif os(iOS)

    public static func getProcessInfo() -> [String:String] {
        var info: [String:String] = [:]
        info["OS"]="iOS"
        
        // FileManager
        info["FileManagerCurrentDirectoryPath"] = FileManager.default.currentDirectoryPath
        info["Argument0"] = ProcessInfo.processInfo.arguments[0]
        print("## CLI arguments = \(CommandLine.arguments)")
        print("## Process arguments = \(ProcessInfo.processInfo.arguments)")
        print("## Process environment = \(ProcessInfo.processInfo.environment)")
        print("## Process processName = \(ProcessInfo.processInfo.processName)")
        if let pwd = ProcessInfo.processInfo.environment["PWD"] {
            info["ProcessInfoPwd"] = pwd
        }
        
        // Bundle
        var i = 0
        for bundle in Bundle.allBundles {
            info["Bundle[\(i)]"] = bundle.bundlePath
            i = i + 1
        }
        
        return info
    }
    
    #endif
    
}
