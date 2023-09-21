//
//  AppDelegate.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable function_body_length

import UIKit
import UserNotifications
// Analytics Frameworks
import Firebase
import FirebaseAnalytics // "Google Analytics"
//import AppTrackingTransparency // only needed if tracking across non-NutritionFacts apps & sites

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    weak var realmDelegate: RealmDelegate?
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let logger = LogService.shared
        logger.logLevel = LogServiceLevel.off
        
        // =====  DEBUG SETUP  =====
        #if DEBUG
        let identifier = Bundle.main.bundleIdentifier ?? "not found"
        print("PRODUCT_BUNDLE_IDENTIFIER = \(identifier)")
        
        printDeviceInfo()
        printLocaleInfo()
        
        print("""
        :#DEBUG:WAYPOINT: AppDelegate didFinishLaunchingWithOptions
        \((URL.inDocuments().path))
        """)
        logger.logLevel = LogServiceLevel.verbose
        logger.useLogFile(nameToken: "dev") // logger.useLogFileDefault()
        logger.debug("""
        ::::: DEBUG :::::
        AppDelegate didFinishLaunchingWithOptions DEBUG enabled
        """)
        
        SQLiteBuiltInTest.shared.runSuite() // :GTD:01: setup initial state
        
        logger.debug(":::::::::::::::::\n")
        #endif
        
        // =====  SIMULATOR SETUP  =====
        #if targetEnvironment(simulator)
        let bundle = Bundle(for: type(of: self))
        logger.debug("""
        ::::: SIMULATOR ENVIRONMENT :::::
        Bundle & Resources Path:\n\(bundle.bundlePath)\n
        App Documents (log files and exports) Directory:\n\(URL.inDocuments().path)\n
        App Library (database) Directory:\n\(URL.inLibrary().path)\n
        """)
        logger.debug(":::::::::::::::::::::::::::::::::\n")
        #endif
        
        // =====  GLOBAL SETUP  =====
        
        // ----- Database Setup -----
        DBMigrationMaintainer.shared.doMigration() // :GTD:02: migrate from initial state
        
        // ----- User Interface Setup -----
        // `0` used for variable number of lines. :???: double check if needed
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
        
        // ----- Notification Setup -----
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (_, error) in
            if let error = error {
                logger.debug("AppDelegate didFinishLaunchingWithOptions \(error.localizedDescription)")
            }
        }
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.backgroundColor = ColorManager.style.mainMedium
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // ----- Google (Firebase) Analytics -----
        FirebaseApp.configure()
        if UserDefaults.standard.bool(forKey: SettingsKeys.analyticsIsEnabledPref) == true {
            Analytics.setAnalyticsCollectionEnabled(true)
            LogService.shared.info("AppDelegate setAnalyticsCollectionEnabled(true)")
        } else {
            Analytics.setAnalyticsCollectionEnabled(false)
            LogService.shared.info("AppDelegate setAnalyticsCollectionEnabled(false)")
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func printDeviceInfo() {
        let device = UIDevice.current
        //let uiIdiom = device.userInterfaceIdiom // phone, pad, tv, mac
        print("""
        DEVICE:
                     model = \(device.model)
                      name = \(device.name)
                systemName = \(device.systemName)
             systemVersion = \(device.systemVersion)
        
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
                scriptCode = \(currentLocale.scriptCode ?? "nil")
               variantCode = \(currentLocale.variantCode ?? "nil")
        
                  calendar = \(currentLocale.calendar)
          usesMetricSystem = \(currentLocale.usesMetricSystem)
        
        """)
    }
    
}
