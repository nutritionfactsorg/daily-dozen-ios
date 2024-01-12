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
        logit.logLevel = LogServiceLevel.off
        
        #if DEBUG && WITH_ANALYTICS
        print("SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG WITH_ANALYTICS")
        #elseif DEBUG && WITHOUT_ANALYTICS
        print("SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG WITHOUT_ANALYTICS")
        #endif
        
        // =====  SIMULATOR ENVIRONMENT  =====
        #if targetEnvironment(simulator)
        let bundle = Bundle(for: type(of: self))
        print("""
        \n::::: SIMULATOR ENVIRONMENT :::::
        Bundle & Resources Path:\n\(bundle.bundlePath)\n
        App Documents Directory:\n\(URL.inDocuments().path)\n
        App Library Directory:\n\(URL.inLibrary().path)\n
        :::::::::::::::::::::::::::::::::\n
        """)
        #endif
        
        // =====  DEBUG SETUP  =====
        #if DEBUG
        logit.logLevel = LogServiceLevel.verbose

        let identifier = Bundle.main.bundleIdentifier ?? "not found"
        print("PRODUCT_BUNDLE_IDENTIFIER = \(identifier)")
        
        printDeviceInfo()
        printLocaleInfo()
        
        print("""
        :DEBUG:WAYPOINT: AppDelegate didFinishLaunchingWithOptions
        \((URL.inDocuments().path))\n
        """)
        logit.useLogFile(nameToken: "dev") // logit.useLogFileDefault()
        logit.debug("""
        ::::: DEBUG :::::
        AppDelegate didFinishLaunchingWithOptions DEBUG enabled
        """)
        
        /// :GTD:UserPrefOverride: SettingsKeys.unitsTypePref Imperial (lbs) | Metric (kgs)
        UserDefaults.standard.set(UnitsType.imperial.rawValue, forKey: SettingsKeys.unitsTypePref)
        //UserDefaults.standard.set(UnitsType.metric.rawValue, forKey: SettingsKeys.unitsTypePref)
        logit.info(":: unitsTypePref==\( SettingsManager.unitsType() )")
        
        /// :GTD:UserPrefOverride: SettingsKeys.exerciseGamutMaxUsed
        UserDefaults.standard.set(ExerciseGamut.one.rawValue, forKey: SettingsKeys.exerciseGamutPref)
        UserDefaults.standard.set(ExerciseGamut.one.rawValue, forKey: SettingsKeys.exerciseGamutMaxUsed)
        //UserDefaults.standard.set(ExerciseGamut.six.rawValue, forKey: SettingsKeys.exerciseGamutPref
        //UserDefaults.standard.set(ExerciseGamut.six.rawValue, forKey: SettingsKeys.exerciseGamutMaxUsed)
        logit.info(":: exerciseGamutMaxUsedInt()==\( SettingsManager.exerciseGamutMaxUsedInt() )")
        
        let s: SQLiteBuiltInTest.InitialState = .db02
        logit.info("••DB_STATE••INITIAL_DEBUG_SETUP••BEGIN•• InitialState=\(s)")
        SQLiteBuiltInTest.shared.setupInitialState(s) // :GTD:B:√: initial DB
        logit.info("••DB_STATE••INITIAL_DEBUG_SETUP•••END••• InitialState=\(s)\n")
        
        #endif
        
        // =====  GLOBAL SETUP  =====
        
        // ----- Database Setup -----
        DBMigrationMaintainer.shared.doMigration() // :GTD:C,D,E: migrate from initial state
        
        // ----- User Interface Setup -----
        // `0` used for variable number of lines. :???: double check if needed
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
        
        // ----- Notification Setup -----
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (_, error) in
            if let error = error {
                logit.debug("AppDelegate didFinishLaunchingWithOptions \(error.localizedDescription)")
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
        // See Project Build Settings `SWIFT_ACTIVE_COMPILATION_CONDITIONS`
        #if WITH_ANALYTICS
        FirebaseApp.configure()
        if UserDefaults.standard.bool(forKey: SettingsKeys.analyticsIsEnabledPref) == true {
            Analytics.setAnalyticsCollectionEnabled(true)
            logit.info("AppDelegate setAnalyticsCollectionEnabled(true)")
        } else {
            Analytics.setAnalyticsCollectionEnabled(false)
            logit.info("AppDelegate setAnalyticsCollectionEnabled(false)")
        }
        logit.info("ANALYTICS is included in the build.")
        #else
        logit.info("ANALYTICS is excluded from the build.")
        #endif
                
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
