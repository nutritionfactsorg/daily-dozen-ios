//
//  AnalyticsHelper.swift
//  DailyDozen
//
//  Copyright © 2022 Nutritionfacts.org. All rights reserved.
//

import UIKit
// Analytics Frameworks
import Firebase
import FirebaseAnalytics // "Google Analytics"

struct AnalyticsHelper {
    static var shared = AnalyticsHelper()
    
    func buildAnalyticsConsentAlert() -> UIAlertController {
        let alertMsgBodyStr = NSLocalizedString("setting_analytics_body", comment: "Analytics request")
        let alertMsgTitleStr = NSLocalizedString("setting_analytics_title", comment: "Analytics title")
        let optInStr = NSLocalizedString("setting_analytics_opt_in", comment: "Opt-In")
        let optOutStr = NSLocalizedString("setting_analytics_opt_out", comment: "Opt-Out")

        let alert = UIAlertController(title: alertMsgTitleStr, message: alertMsgBodyStr, preferredStyle: .alert)
        let optOutAction = UIAlertAction(title: optOutStr, style: .default) {
            (_: UIAlertAction) -> Void in
            self.doAnalyticsDisable()
        }
        alert.addAction(optOutAction)
        let optInAction = UIAlertAction(title: optInStr, style: .default) {
            (_: UIAlertAction) -> Void in
            self.doAnalyticsEnable()
        }
        alert.addAction(optInAction)
        return alert
        // use: present(alert, animated: true, completion: nil)
    }
    
    func doAnalyticsEnable() {
        //if FirebaseApp.app() == nil {
        //    FirebaseApp.configure()
        //}
        Analytics.setAnalyticsCollectionEnabled(true)
        UserDefaults.standard.set(true, forKey: SettingsKeys.analyticsIsEnabledPref)
        LogService.shared.info("AnalyticsHelper doAnalyticsEnable() completed")
    }
    
    func doAnalyticsDisable() {
        if FirebaseApp.app() != nil {
            Analytics.setAnalyticsCollectionEnabled(false)
            LogService.shared.info("AnalyticsHelper doAnalyticsDisable() disabled existing FirebaseApp Analytics")
        }
        UserDefaults.standard.set(false, forKey: SettingsKeys.analyticsIsEnabledPref)
        LogService.shared.info("AnalyticsHelper doAnalyticsDisable() completed")
    }
}
