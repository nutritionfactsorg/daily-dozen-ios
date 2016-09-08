//
//  CheckboxButton.swift
//  DailyDozen
//
//  Created by Will Webb on 9/4/16.
//  Copyright © 2016 NutritionFacts.org. All rights reserved.
//

import UIKit

class CheckboxButton: UIButton {
    
    let checkedImage = UIImage(named: "images/checkmark_filled")
    let uncheckedImage = UIImage(named: "images/checkmark_unfilled")
    
    var checked: Bool = false {
        
        didSet {
            
            setImage(checked ? checkedImage : uncheckedImage, forState: .Normal)
            tintColor = checked ? UIColor(red: 0xff/255.0, green: 0x52/255.0, blue: 0x52/255.0, alpha: 1.0) : UIColor.blackColor()
        }
    }
    
    override func awakeFromNib() {
        
        addTarget(self, action: #selector(CheckboxButton.onClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        checked = false
    }
    
    func onClick(sender: UIButton) {
        
        if(sender == self) {
            
            checked = !checked
        }
    }
}
