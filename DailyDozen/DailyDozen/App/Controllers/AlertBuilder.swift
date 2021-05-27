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
        static let dozeOtherInfoTitle = NSLocalizedString("dozeOtherInfo.title", comment: "Daily Dozen other info title")
        static let dozeOtherInfoMessage = NSLocalizedString("dozeOtherInfo.message", comment: "Daily Dozen other info message")
        static let dozeOtherInfoConfirm = NSLocalizedString("dozeOtherInfo.confirm", comment: "Daily Dozen other info confirm")
    }

    private struct Keys {
        static let title = "attributedTitle"
        static let message = "attributedMessage"
        static let textColor = "titleTextColor"
    }

    enum AlertContent {

        case dietarySupplement

        var title: String {
            switch self {
            case .dietarySupplement:
                return Strings.dozeOtherInfoTitle
            }
        }

        var message: String {
            switch self {
            case .dietarySupplement:
                return Strings.dozeOtherInfoMessage
            }
        }
    }

    static func newInstance(for content: AlertContent) -> UIAlertController {
        let alert = UIAlertController(title: content.title, message: content.message, preferredStyle: .alert)

        alert.setValue(
            NSAttributedString(
                string: content.title,
                attributes: [
                    NSAttributedString.Key.font: UIFont.helveticaBold,
                    NSAttributedString.Key.foregroundColor: ColorManager.style.mainMedium]),
            forKey: Keys.title)

        let message = NSAttributedString(
            string: content.message,
            attributes: [
                NSAttributedString.Key.font: UIFont.helevetica,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        alert.setValue(message, forKey: Keys.message)

        let action = UIAlertAction(title: Strings.dozeOtherInfoConfirm, style: .cancel, handler: nil)
        action.setValue(ColorManager.style.mainMedium, forKey: Keys.textColor)
        alert.addAction(action)

        return alert
    }
}
