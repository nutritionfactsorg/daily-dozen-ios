//
//  ViewController.swift
//  DailyDozen
//
//  Created by Will Webb on 9/1/16.
//  Copyright © 2016 NutritionFacts.org. All rights reserved.
//

import UIKit

class ServingsController: UIViewController, UITableViewDataSource {
    
    let servingNames = ["Beans", "Berries", "Other Fruits", "Cruciferous Vegetables", "Greens", "Other Vegetables", "Flaxseeds", "Nuts", "Spices", "Whole Grains", "Beverages", "Exercise"]
    let servingImages = ["ic_beans", "ic_berries", "ic_other_fruits", "ic_cruciferous", "ic_greens", "ic_other_veg", "ic_flax", "ic_nuts", "ic_spices", "ic_whole_grains", "ic_beverages", "ic_exercise"]
    let servingSizes = [3, 1, 3, 1, 2, 2, 1, 1, 1, 3, 5, 1]

    @IBOutlet weak var servingTableView: UITableView!
    @IBOutlet weak var dateTabBar: UITabBar!
    @IBOutlet weak var titleNavigationBar: UINavigationBar!
    @IBOutlet weak var menuButtonBarItem: UIBarButtonItem!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return servingNames.count
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
    
        servingImage.image = UIImage(named: "images/" + servingImages[indexPath.row])
        servingImage.contentMode = .Center
        servingText.text = servingNames[indexPath.row]
        for checkboxIndex in 0...4 {
            
            servingCheckboxes[checkboxIndex].hidden = !(checkboxIndex < servingSizes[indexPath.row])
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
        /// TODO: load the selected date into an array (if found in db) for viewing
    }

    override func didReceiveMemoryWarning() {
    
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

