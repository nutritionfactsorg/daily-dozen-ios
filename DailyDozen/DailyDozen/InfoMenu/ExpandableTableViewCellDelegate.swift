//
//  ExpandableTableViewCellDelegate.swift
//  DailyDozen
//
//  Copyright © 2023 Nutritionfacts.org. All rights reserved.
//

import UIKit

protocol ExpandableTableViewCellDelegate: AnyObject {
    func expandableTableViewCell(_ tableViewCell: UITableViewCell, expanded: Bool)
}
