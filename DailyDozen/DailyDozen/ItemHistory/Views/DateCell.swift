//
//  DateCell.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 21.11.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import FSCalendar

class DateCell: FSCalendarCell {

    private weak var borderView: UIView!

    var borderColor = UIColor.white {
        didSet {
            borderView.backgroundColor = borderColor
            setNeedsLayout()
        }
    }

    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let borderView = UIView()

        contentView.insertSubview(borderView, at: 0)
        self.borderView = borderView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderView.frame = eventIndicator.frame.insetBy(dx: 20, dy: 1)
    }
}
