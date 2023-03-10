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
    
    @IBAction func clearDbBtn(_ sender: UIButton) {
        SqliteConnector.run.clearDb()
    }
    
    @IBAction func createDataBtn(_ sender: UIButton) {
        SqliteConnector.run.createData()
    }
    
    @IBAction func exportDataBtn(_ sender: UIButton) {
        SqliteConnector.run.exportData()
    }
    
    @IBAction func importDataBtn(_ sender: UIButton) {
        SqliteConnector.run.importData()
    }
    
    @IBAction func timingTest(_ sender: UIButton) {
        SqliteConnector.run.timingTest()
    }
    
}

