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
        
        // =====  DEBUG SETUP  =====
        #if DEBUG
        logit.logLevel = LogServiceLevel.verbose
        logit.useLogFile(nameToken: "dev") // logit.useLogFileDefault()

        let identifier = Bundle.main.bundleIdentifier ?? "not found"
        logit.info("PRODUCT_BUNDLE_IDENTIFIER = \(identifier)")
        
        logDeviceInfo()
        logLocaleInfo()
        
        logit.info("""
        :DEBUG:WAYPOINT: AppDelegate didFinishLaunchingWithOptions
        \((URL.inDocuments().path))\n
        """)
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
        
        // =====  ANALYTICS ENVIRONMENT  =====
        #if DEBUG && WITH_ANALYTICS
        logit.info("SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG WITH_ANALYTICS")
        #elseif DEBUG && WITHOUT_ANALYTICS
        logit.info("SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG WITHOUT_ANALYTICS")
        #endif
        
        // =====  SIMULATOR ENVIRONMENT  =====
        #if targetEnvironment(simulator)
        let bundle = Bundle(for: type(of: self))
        logit.info("""
        \n::::: SIMULATOR ENVIRONMENT :::::
        Bundle & Resources Path:\n\(bundle.bundlePath)\n
        App Documents Directory:\n\(URL.inDocuments().path)\n
        App Library Directory:\n\(URL.inLibrary().path)\n
        :::::::::::::::::::::::::::::::::\n
        """)
        
        // =====  DEBUG: XCODE 15.1/.2/… DEBUGGER WORKAROUND  =====
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        if systemName == "iOS",
           systemVersion.hasPrefix("15") || systemVersion.hasPrefix("16") {
            pauseDebug()
        }
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
    
    func pauseDebug() {
        // =====  DEBUG: XCODE 15.1/.2/… DEBUGGER WORKAROUND  =====
        logit.logLevel = LogServiceLevel.verbose
        let logitpath = logit.logfileUrl?.absoluteString ?? "logpath not available"
        logit.debug("""
        \n::::: WORKAROUND: PAUSE 1 :::::
        Workaround: Xcode 15.• debugger not auto-attaching to iOS 15/16 simulator
        logit file path:
        \(logitpath)
        
        NEXT STEPS: 
        • Copy any required info (e.g. logit path) before a detach/attach cycle.
        • Currently, detach/attach clears the debug console.
        • Any print() further statements may not have debug console output.
        • The logit file will continue to update.
        
        … then, Detach from DailyDozen process.
        :::::::::::::::::::::::::::::::::\n
        """)
        pause()

        logit.debug("""
        \n::::: WORKAROUND: PAUSE 2 :::::
        NEXT STEP: Attach to Process > DailyDozen
        :::::::::::::::::::::::::::::::::\n
        """)
        pause()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func logDeviceInfo() {
        let device = UIDevice.current
        //let uiIdiom = device.userInterfaceIdiom // phone, pad, tv, mac
        logit.info("""
        DEVICE:
                     model = \(device.model)
                      name = \(device.name)
                systemName = \(device.systemName)
             systemVersion = \(device.systemVersion)
        
        """)
    }
    
    func logLocaleInfo() {
        let currentLocale = Locale.current
        logit.info("""
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
