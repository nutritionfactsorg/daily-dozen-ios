//
//  AlertBuilder.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 30.01.2018.
//  Copyright © 2018 Nutritionfacts.org. All rights reserved.
//

import UIKit

class AlertBuilder {

    // MARK: - Nested
    private struct Strings {
        static let vitamins = "VITAMINS"
        static let message = """
        Vitamin B12 and Vitamin D are essential for your health but do not count towards your daily servings.

        They are included in this app to provide you with an easy way to track your intake.
        """
        static let confirm = "OK"
    }

    private struct Keys {
        static let title = "attributedTitle"
        static let message = "attributedMessage"
        static let textColor = "titleTextColor"
    }

    enum AlertContent {

        case vitamin

        var title: String {
            switch self {
            case .vitamin:
                return Strings.vitamins
            }
        }

        var message: String {
            switch self {
            case .vitamin:
                return Strings.message
            }
        }
    }

    static func instantiateController(for content: AlertContent) -> UIAlertController {
        let alert = UIAlertController(title: content.title, message: content.title, preferredStyle: .actionSheet)

        alert.setValue(
            NSAttributedString(
                string: content.title,
                attributes: [
                    NSAttributedString.Key.font: UIFont.helveticaBold,
                    NSAttributedString.Key.foregroundColor: UIColor.greenColor]),
            forKey: Keys.title)

        alert.setValue(
            NSAttributedString(
                string: content.message,
                attributes: [
                    NSAttributedString.Key.font: UIFont.helevetica,
                    NSAttributedString.Key.foregroundColor: UIColor.lightGray]),
            forKey: Keys.message)

        let action = UIAlertAction(title: Strings.confirm, style: .cancel, handler: nil)
        action.setValue(UIColor.greenColor, forKey: Keys.textColor)
        alert.addAction(action)

        return alert
    }
}
