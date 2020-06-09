//
//  FirstLaunchViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

class FirstLaunchBuilder {
    
    // MARK: Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> FirstLaunchViewController {
        let storyboard = UIStoryboard(name: "FirstLaunch", bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? FirstLaunchViewController
            else { fatalError("Did not instantiate `FirstLaunchViewController`") }
        viewController.title = ""
        
        return viewController
    }
}

class FirstLaunchViewController: UIViewController {
    
    @IBAction func dailyDozenOnly(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: SettingsKeys.hasSeenFirstLaunch)
        UserDefaults.standard.set(false, forKey: SettingsKeys.show21TweaksPref)
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "NoticeUpdatedShowTweaksTab"),
            object: 0,
            userInfo: nil)
    }
    
    @IBAction func dozenPlusTweaks(_ sender: Any) {
        //NYI: Insert Weight permisisons here
        UserDefaults.standard.set(true, forKey: SettingsKeys.hasSeenFirstLaunch)
        UserDefaults.standard.set(true, forKey: SettingsKeys.show21TweaksPref)
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "NoticeUpdatedShowTweaksTab"),
            object: 1,
            userInfo: nil)
    }
    
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
        // Do any additional setup after loading the view.
    }
    
}
