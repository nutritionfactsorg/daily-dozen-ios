//
//  AppDelegate.swift
//  SqliteMigrateLegacy12
//
//  Copyright © 2023 NutritionFacts.org. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        print("PRODUCT_BUNDLE_IDENTIFIER = \(Bundle.main.bundleIdentifier ?? "not found")")
        printDeviceInfo()
        printLocaleInfo()
        
        print("•DEBUG•WAYPOINT• AppDelegate didFinishLaunchingWithOptions\n\((URL.inDocuments().path))")
        print("••••• DEBUG •••••\nAppDelegate didFinishLaunchingWithOptions DEBUG enabled")
        print("•••••••••••••••••\n")
        #endif
        
        #if targetEnvironment(simulator)
        let bundle = Bundle(for: type(of: self))
        print("""
        •••••• SIMULATOR ENVIRONMENT •••••
        Bundle & Resources Path:\n\(bundle.bundlePath)\n
        App Documents (log files and exports) Directory:\n\(URL.inDocuments().path)\n
        App Library (database) Directory:\n\(URL.inLibrary().path)\n
        """)
        print("•••••••••••••••••••••••••••••••••\n")
        #endif
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
    
    // MARK: - Runtime Information
    
    func printDeviceInfo() {
        let device = UIDevice.current
        print("""
        DEVICE:
                     model = \(device.model)
                      name = \(device.name)
                systemName = \(device.systemName)
             systemVersion = \(device.systemVersion)\n
        """)
    }
    
    func printLocaleInfo() {
        let currentLocale = Locale.current
        print("""
        LOCALE:
          decimalSeparator = \(currentLocale.decimalSeparator ?? "nil")
                identifier = \(currentLocale.identifier)
              languageCode = \(currentLocale.languageCode ?? "nil")
                regionCode = \(currentLocale.regionCode ?? "nil")
                  calendar = \(currentLocale.calendar)
          usesMetricSystem = \(currentLocale.usesMetricSystem)\n
        """)
    }
}
