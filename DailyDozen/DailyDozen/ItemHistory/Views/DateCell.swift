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

    // MARK: - Properties
    private weak var borderView: UIView!

    // MARK: - Inits
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let borderView = UIView()
        contentView.insertSubview(borderView, at: 1)

        self.borderView = borderView
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let dx = (titleLabel.bounds.width - titleLabel.bounds.height) / 2
        borderView.frame = titleLabel.bounds.insetBy(dx: dx + 2, dy: 2)
        borderView.layer.cornerRadius = borderView.bounds.width / 2
    }

    // MARK: - Methods
    /// Sets the borderView color.
    ///
    /// - Parameters:
    ///   - count: The current states count.
    ///   - maximum: The maximum of states.
    func configure(for count: Int, maximum: Int) {
        if count == maximum {
            borderView.backgroundColor = UIColor.yellowColor
        } else if count > 0 {
            borderView.backgroundColor = UIColor.yellow
        } else {
            borderView.backgroundColor = UIColor.white
        }
        setNeedsLayout()
    }
}
