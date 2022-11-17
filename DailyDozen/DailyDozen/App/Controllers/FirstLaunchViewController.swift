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
    
    @IBOutlet weak var settingDozeOnlyButton: UIButton!
    @IBOutlet weak var settingDozeTweakButton: UIButton!
    
    // Actions
    
    @IBAction func dailyDozenOnlyBtnAction(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: SettingsKeys.hasSeenFirstLaunch)
        UserDefaults.standard.set(false, forKey: SettingsKeys.show21TweaksPref)
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "NoticeUpdatedShowTweaksTab"),
            object: 0,
            userInfo: nil)
    }
    
    @IBAction func dozenPlusTweaksBtnAction(_ sender: UIButton) {
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
                
        settingDozeOnlyButton.backgroundColor = ColorManager.style.mainMedium
        settingDozeOnlyButton.tintColor = ColorManager.style.mainMedium
        settingDozeOnlyButton.setTitleColor(UIColor.white, for: .normal)
        settingDozeOnlyButton.layer.cornerRadius = 10
        settingDozeOnlyButton.layer.shadowRadius = 10
        settingDozeOnlyButton.titleLabel?.textAlignment = .center
        settingDozeOnlyButton.setTitle(
            NSLocalizedString("setting_doze_only_btn", comment: "Daily Dozen\nOnly"),
            for: .normal)
        settingDozeOnlyButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        settingDozeTweakButton.backgroundColor = ColorManager.style.mainMedium
        settingDozeTweakButton.tintColor = ColorManager.style.mainMedium
        settingDozeTweakButton.setTitleColor(UIColor.white, for: .normal)
        settingDozeTweakButton.layer.cornerRadius = 10
        settingDozeTweakButton.layer.shadowRadius = 10
        settingDozeTweakButton.titleLabel?.textAlignment = .center
        settingDozeTweakButton.setTitle(
            NSLocalizedString("setting_doze_tweak_btn", comment: "Daily Dozen +\n21 Tweaks"),
            for: .normal)
        settingDozeTweakButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
}
