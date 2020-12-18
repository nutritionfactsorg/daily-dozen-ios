//
//  UIView.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import UIKit

extension UIView {
    func subviews<T: UIView>(ofType whatType: T.Type) -> [T] {
        var result = self.subviews.compactMap {$0 as? T}
        for sub in self.subviews {
            result.append(contentsOf: sub.subviews(ofType: whatType))
        }
        return result
    }
}
