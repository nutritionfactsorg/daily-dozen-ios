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

public class ServingsController: UIViewController, UITableViewDataSource, UITabBarDelegate {
    let OneDay : NSTimeInterval = 86400
    
    @IBOutlet weak var currentDateTabBarItem: UITabBarItem!
    @IBOutlet weak var todayTabBarItem: UITabBarItem!
    @IBOutlet weak var nextTabBarItem: UITabBarItem!
    @IBOutlet weak var previousTabBarItem: UITabBarItem!
    @IBOutlet weak var servingTableView: UITableView!
    @IBOutlet weak var dateTabBar: UITabBar!
    @IBOutlet weak var titleNavigationBar: UINavigationBar!
    @IBOutlet weak var menuButtonBarItem: UIBarButtonItem!
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return Servings.ServingNames.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
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
        
        updateTabBarItems()
        
        return cell
    }
    
    func updateTabBarItems() {
        todayTabBarItem.enabled = !displayServings.isToday()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        currentDateTabBarItem.title = dateFormatter.stringFromDate(displayServings.date)
        previousTabBarItem.title = dateFormatter.stringFromDate(displayServings.date.dateByAddingTimeInterval(-OneDay))
        nextTabBarItem.title = todayTabBarItem.enabled ? dateFormatter.stringFromDate(displayServings.date.dateByAddingTimeInterval(OneDay)) : ""
        nextTabBarItem.enabled = todayTabBarItem.enabled
        
        dateTabBar.selectedItem = currentDateTabBarItem
    }
    
    public func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item == todayTabBarItem {
            displayServings = Servings.getServingsByDate(NSDate())
        } else if item == previousTabBarItem {
            displayServings = Servings.getServingsByDate(displayServings.date.dateByAddingTimeInterval(-OneDay))
        } else if item == nextTabBarItem {
            if !displayServings.isToday() {
                displayServings = Servings.getServingsByDate(displayServings.date.dateByAddingTimeInterval(OneDay))
            }
        }
        
        updateTabBarItems()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.servingTableView.reloadData()
        })
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
    }
    
    override public func viewDidLoad() {
    
        super.viewDidLoad()
        
        servingTableView.dataSource = self
        dateTabBar.delegate = self
        
        /// load the selected date into an array (if found in db) for viewing
        displayServings = Servings.getServingsByDate(displayServings.date)
    }

    override public func didReceiveMemoryWarning() {
    
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

