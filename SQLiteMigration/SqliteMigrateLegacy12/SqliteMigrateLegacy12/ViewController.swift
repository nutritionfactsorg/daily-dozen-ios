//
//  ViewController.swift
//  SqliteMigrateLegacy12
//
//  Copyright © 2023 NutritionFacts.org. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    /// Clear DB
    @IBAction func clearDbBtn(_ sender: UIButton) {
        SqliteConnector.run.clearDb()
    }
    
    /// Create Data
    @IBAction func createDataBtn(_ sender: UIButton) {
        SqliteConnector.run.createData()
    }
    
    /// Export Data
    @IBAction func exportDataBtn(_ sender: UIButton) {
        SqliteConnector.run.exportData()
    }
    
    /// Import Data
    @IBAction func importDataBtn(_ sender: UIButton) {
        SqliteConnector.run.importData()
    }
    
    /// Timing Test
    @IBAction func timingTestBtn(_ sender: UIButton) {
        SqliteConnector.run.timingTest()
    }
    
}

