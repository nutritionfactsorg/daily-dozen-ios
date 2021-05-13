//
//  FirstLaunchViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

class FirstLaunchViewController: UIViewController {
    
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func newInstance() -> FirstLaunchViewController {
        let storyboard = UIStoryboard(name: "FirstLaunch", bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? FirstLaunchViewController
            else { fatalError("Did not instantiate `FirstLaunchViewController`") }
        viewController.title = ""
        
        return viewController
    }
    
    // Outlets
    
    @IBOutlet weak var settingHealthAloneLabel: UILabel!
    @IBOutlet weak var settingHealthWeightLabel: UILabel!
    @IBOutlet weak var settingDozeOnlyBtn: UIButton!
    @IBOutlet weak var settingDozeTweakBtn: UIButton!
        
    // Actions
    
    @IBAction func dailyDozenOnly(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: SettingsKeys.hasSeenFirstLaunch)
        UserDefaults.standard.set(false, forKey: SettingsKeys.show21TweaksPref)
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "NoticeUpdatedShowTweaksTab"),
            object: 0,
            userInfo: nil)
    }
    
    @IBAction func dozenPlusTweaks(_ sender: Any) {
        // NYI: Insert Weight permisisons here
        UserDefaults.standard.set(true, forKey: SettingsKeys.hasSeenFirstLaunch)
        UserDefaults.standard.set(true, forKey: SettingsKeys.show21TweaksPref)
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "NoticeUpdatedShowTweaksTab"),
            object: 1,
            userInfo: nil)
    }
    
    // :???: Main.storyboard appears to no longer be in use.
    func prepareNextViewController() {
        UserDefaults.standard.set(true, forKey: "didSee")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "mainVC")
        self.navigationController?.setViewControllers([mainVC], animated: true)
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingHealthAloneLabel.text = NSLocalizedString("setting_health_alone_txt", comment: "For Health Alone")
        settingHealthWeightLabel.text = NSLocalizedString("setting_health_weight_txt", comment: "For Health and Weight Loss")
        settingDozeOnlyBtn.backgroundColor = ColorManager.style.mainMedium
        settingDozeOnlyBtn.setTitleColor(UIColor.white, for: .normal)
        settingDozeOnlyBtn.setTitle(
            NSLocalizedString("setting_doze_only_btn", comment: "Daily Dozen\nOnly"),
            for: .normal)
        settingDozeTweakBtn.backgroundColor = ColorManager.style.mainMedium
        settingDozeTweakBtn.setTitleColor(UIColor.white, for: .normal)
        settingDozeTweakBtn.setTitle(
            NSLocalizedString("setting_doze_tweak_btn", comment: "Daily Dozen +\n21 Tweaks"),
            for: .normal)
    }
    
}
