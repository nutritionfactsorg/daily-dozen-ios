//
//  SlideOutMenuController.swift
//  DailyDozen
//
//  Created by Will Webb on 9/12/16.
//  Copyright © 2016 NutritionFacts.org. All rights reserved.
//

import UIKit

class SlideOutMenuController: UITableViewController {
    
    let menuItemNames = ["", "Latest Videos", "How Not To Die", "Donate", "Subscribe", "Open Source", "Daily Reminders", "Backup", "About"]
    let menuItemImages = ["", "ic_latest_videos", "ic_book", "ic_donate", "ic_subscribe", "ic_open_source", "ic_reminders", "ic_backup", "ic_about"]
    let menuItemLinks = ["", "videos", "book", "donate", "subscribe", "open-source", "", "", ""]
    
    @IBOutlet var menuTableView: UITableView!
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = menuTableView.dequeueReusableCellWithIdentifier("MenuItemCell") as UITableViewCell!
        let menuItemImage = cell.contentView.viewWithTag(3) as! UIImageView
        let menuItemText = cell.contentView.viewWithTag(2) as! UILabel
        
        menuItemImage.image = UIImage(named: "images/" + menuItemImages[indexPath.row])
        menuItemImage.contentMode = .Center
        menuItemText.text = menuItemNames[indexPath.row]
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(netHex: 0x4CAF50)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if menuItemLinks[indexPath.row].characters.count > 0 {
            let url = NSURL(string: "https://nutritionfacts.org/" + menuItemLinks[indexPath.row] + "/")
            UIApplication.sharedApplication().openURL(url!)
        }
        else {
            //TODO: handle about, backup, daily reminders
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
