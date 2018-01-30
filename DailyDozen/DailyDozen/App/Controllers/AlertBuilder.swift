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
        static let helveticaBold = "Helvetica-Bold"
        static let helvetica = "Helvetica"
        static let title = "attributedTitle"
        static let message = "attributedMessage"
        static let textColor = "titleTextColor"
    }

    private struct Sizes {
        static let titleFontSize: CGFloat = 22
        static let messageFontSize: CGFloat = 17
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

        var titleFontSize: CGFloat {
            switch self {
            case .vitamin:
                return Sizes.titleFontSize
            }
        }

        var messageFontSize: CGFloat {
            switch self {
            case .vitamin:
                return Sizes.messageFontSize
            }
        }
    }

    static func instantiateController(for content: AlertContent) -> UIAlertController {
        let alert = UIAlertController(title: content.title, message: content.title, preferredStyle: .actionSheet)

        let titleSize = Sizes.titleFontSize
        alert.setValue(
            NSAttributedString(
                string: content.title,
                attributes: [
                    NSAttributedStringKey.font:
                        UIFont(name: Keys.helveticaBold, size: titleSize) ?? UIFont.systemFont(ofSize: titleSize),
                    NSAttributedStringKey.foregroundColor: UIColor.greenColor]),
            forKey: Keys.title)

        let messageSize = Sizes.messageFontSize
        alert.setValue(
            NSAttributedString(
                string: content.message,
                attributes: [
                    NSAttributedStringKey.font:
                        UIFont(name: Keys.helvetica, size: messageSize) ?? UIFont.systemFont(ofSize: messageSize),
                    NSAttributedStringKey.foregroundColor: UIColor.lightGray]),
            forKey: Keys.message)

        let action = UIAlertAction(title: Strings.confirm, style: .cancel, handler: nil)
        action.setValue(UIColor.greenColor, forKey: Keys.textColor)
        alert.addAction(action)

        return alert
    }
}
