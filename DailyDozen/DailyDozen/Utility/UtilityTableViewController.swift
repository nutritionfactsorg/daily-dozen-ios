//
//  UtilityTableViewController.swift
//  DailyDozen
//
//  Created by marc on 2019.11.04.
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

// MARK: - Builder 
class UtilityBuilder {

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Utility", bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController()
            else { fatalError("Did not instantiate `Utility` controller") }
        viewController.title = "Utility"

        return viewController
    }
}

// MARK: - Controller
class UtilityTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("didSelectRowAt section:\(indexPath.section), row \(indexPath.row)")
        
        if indexPath.section == 0 {
            // Database Maintenance
            if indexPath.row == 0 {
                // Backup Database
            } else {
                // Restore Database
                
            }
        } else {
            // Database Migration
            if indexPath.row == 0 {
                // Create Legacy Database
            } else {
                // Migrage Database
            
            }
        }

        tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
