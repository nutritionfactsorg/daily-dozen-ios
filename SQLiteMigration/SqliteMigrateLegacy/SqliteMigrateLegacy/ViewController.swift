//
//  ViewController.swift
//  SqliteMigrateLegacy
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    
    
    @IBAction func timingTestBtn(_ sender: UIButton) {
        SqliteConnector.run.timingTest()
    }
    
}

