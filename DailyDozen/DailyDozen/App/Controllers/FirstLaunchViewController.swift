//
//  FirstLaunchViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

class FirstLaunchBuilder {

    // MARK: Nested
    private struct Strings {
        static let storyboard = "FirstLaunch"
    }

    // MARK: Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> FirstLaunchViewController {
        let storyboard = UIStoryboard(name: Strings.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? FirstLaunchViewController
            else { fatalError("Did not instantiate `FirstLaunch` controller") }
        viewController.title = ""

        return viewController
    }
}

class FirstLaunchViewController: UIViewController {
   
    @IBAction func dailyDozenOnly(_ sender: Any) {
        //UserDefaults.standard.set(true, forKey: "didSee")
        // self.performSegue(withIdentifier: "goToMain", sender: self)
        prepareNextViewController()
        
    }
    
    @IBAction func dozenPlusTweaks(_ sender: Any) {
        //NYI: Insert Weight permisisons here
       // UserDefaults.standard.set(true, forKey: "didSee")
        //self.performSegue(withIdentifier: "goToMain", sender: self)
        
        prepareNextViewController()
    }
    
    func prepareNextViewController() {
        UserDefaults.standard.set(true, forKey: "didSee")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "mainVC")
        self.navigationController?.setViewControllers([mainVC], animated: true)
        mainVC.modalPresentationStyle = .fullScreen
        //self.dismiss(animated: false, completion: nil)
        self.present(mainVC, animated: true, completion: nil)
//        navigationController?.viewControllers.removeAll(where: { (vc) -> Bool in
//            if vc.isKind(of: FirstLaunchViewController.self) {
//                return false
//            } else {
//                return true
//            }
//        })
//        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
//
//if let navigator = navigationController {
                 // navigator.pushViewController(mainVC, animated: true)
                //  }
//              }
    }
    
//    func swapRootViewController(newController: UIViewController) {
//        if let window = self.window {
//            window.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
//
//            UIView.transitionWithView(window, duration: 0.3, options: .TransitionCrossDissolve, animations: {
//                window.rootViewController = newController
//            }, completion: nil)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
  // override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    //}

}
