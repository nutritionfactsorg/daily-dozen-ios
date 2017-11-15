//
//  VitaminsViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 15.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class VitaminsViewController: UIViewController {

    weak var tapDelegate: Interactable?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.isOpaque = false
        view.backgroundColor = UIColor.clear
    }

    @IBAction private func viewTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
        tapDelegate?.viewDidTap()
    }
}
