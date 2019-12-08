//
//  WeightViewController.swift
//  DailyDozen
//
//  Created by marc on 2019.12.08.
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit
import StoreKit

class WeightViewController: UIViewController {
    
    // MARK: - Outlets
    // :---: Text Edit
    
    // MARK: - Properties
    private let realm = RealmProvider()
    private let weightStateCountMaximum = 24
        
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewModel(for: Date())
        
        // :---:
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.realmDelegate = self
    }
    
    // MARK: - Methods
    /// Sets a view model for the current date.
    ///
    /// - Parameter item: The current date.
    func setViewModel(for date: Date) {
        
        // :---: get the data for this date
        
        // :---: short the data for this date

    }
    
    // MARK: - Actions
    
    // :---: saveButton
    
    // :---: cancelButton
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WeightViewController: RealmDelegate {
    func didUpdateFile() {
        navigationController?.popViewController(animated: false)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
