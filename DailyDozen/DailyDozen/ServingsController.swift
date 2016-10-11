//
//  ViewController.swift
//  DailyDozen
//
//  Created by Will Webb on 9/1/16.
//  Copyright © 2016 NutritionFacts.org. All rights reserved.
//

import UIKit
import Amigo

var displayServings: Servings = Servings()

class ServingsController: UIViewController, UITableViewDataSource {
    
    var displayDate = Servings.getDatabaseDate(NSDate())

    @IBOutlet weak var servingTableView: UITableView!
    @IBOutlet weak var dateTabBar: UITabBar!
    @IBOutlet weak var titleNavigationBar: UINavigationBar!
    @IBOutlet weak var menuButtonBarItem: UIBarButtonItem!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return Servings.ServingNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell: UITableViewCell = servingTableView.dequeueReusableCellWithIdentifier("ServingCell") as UITableViewCell!
        let servingImage = cell.contentView.viewWithTag(1) as! UIImageView
        let servingText = cell.contentView.viewWithTag(2) as! UILabel
        let servingInfoButton = cell.contentView.viewWithTag(3) as! UIButton
        let servingCheckboxes = [
            cell.contentView.viewWithTag(8) as! CheckboxButton,
            cell.contentView.viewWithTag(7) as! CheckboxButton,
            cell.contentView.viewWithTag(6) as! CheckboxButton,
            cell.contentView.viewWithTag(5) as! CheckboxButton,
            cell.contentView.viewWithTag(4) as! CheckboxButton,
        ]
        let servingDateButton = cell.contentView.viewWithTag(9) as! UIButton
    
        servingImage.image = UIImage(named: "images/" + Servings.ServingImages[indexPath.row])
        servingImage.contentMode = .Center
        servingText.text = Servings.ServingNames[indexPath.row]
        
        for checkboxIndex in 0...4 {
            servingCheckboxes[checkboxIndex].hidden = !(checkboxIndex < Servings.ServingSizes[indexPath.row])
            if !servingCheckboxes[checkboxIndex].hidden {
                servingCheckboxes[checkboxIndex].servingIndex = indexPath.row
                servingCheckboxes[checkboxIndex].checked = displayServings.getServingByIndex(indexPath.row) > checkboxIndex
            }
        }
        servingDateButton.setImage(UIImage(named: "images/ic_calendar"), forState: .Normal)
        servingDateButton.contentMode = .Center
        
        return cell
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
    }
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        servingTableView.dataSource = self
        
        /// load the selected date into an array (if found in db) for viewing
        let session = amigo.session
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "mm/dd/yyyy"
        var servings : Servings? = session.query(Servings).filter("day = '" + dateFormatter.stringFromDate(displayDate!) + "'").get(1)
        if servings != nil {
            displayServings = servings!
        }
        else {
            //TEST
            servings = session.query(Servings).get(1)
            if servings != nil {
                displayServings = servings!
            }
        }
        
        //redraw?
    }

    override func didReceiveMemoryWarning() {
    
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

