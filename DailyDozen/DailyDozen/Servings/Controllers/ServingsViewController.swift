//
//  ServingsViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class ServingsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var dataProvider: ServingsDataProvider!
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Properties
    private let realm = RealmProvider()

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        setViewModel(for: Date())

        tableView.dataSource = dataProvider
        tableView.delegate = self
    }

    // MARK: - Methods
    /// Sets a view model for the current date.
    ///
    /// - Parameter item: The current date.
    func setViewModel(for date: Date) {
        dataProvider.viewModel = DozeViewModel(doze: realm.getDoze(for: date))
        tableView.reloadData()
    }

    // MARK: - Actions
    @IBAction private func infoPressed(_ sender: UIButton) {
        let itemName = dataProvider.viewModel.itemName(for: sender.tag)
        guard !itemName.contains("Vitamin") else {
            let url = dataProvider.viewModel.topicURL(for: itemName)
            UIApplication.shared
                .open(url,
                      options: [:],
                      completionHandler: nil)
            return
        }
        let viewController = DetailsBuilder.instantiateController(with: itemName)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction private func vitaminHeaderPressed(_ sender: UIButton) {
        let viewController = VitaminsViewController(nibName: "VitaminsInfo", bundle: nil)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.tapDelegate = self

        present(viewController, animated: true)
        blurBackground()
    }

    private func blurBackground() {
        guard let parent = parent else { return }
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.8
        blurEffectView.frame = parent.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 100
        parent.view.addSubview(blurEffectView)
    }

    private func unblurBackground() {
        guard let parent = parent else { return }
        for view in parent.view.subviews {
            if let blurView = view as? UIVisualEffectView, blurView.tag == 100 {
                blurView.removeFromSuperview()
            }
        }
    }
}

// MARK: - Servings UITableViewDelegate
extension ServingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let servingsCell = cell as? ServingsCell else { return }
        servingsCell.stateCollection.delegate = self
        servingsCell.stateCollection.dataSource = dataProvider
        servingsCell.stateCollection.reloadData()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? nil : Bundle.main
            .loadNibNamed("VitaminsHeader", owner: nil)?.first as? UIView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 50
    }
}

// MARK: - States UICollectionViewDelegate
extension ServingsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var states = dataProvider.viewModel.itemStates(for: collectionView.tag)
        states[indexPath.row] = !states[indexPath.row]
        guard let cell = collectionView.cellForItem(at: indexPath) as? StateCell else {
            fatalError("There should be a cell")
        }
        cell.configure(with: states[indexPath.row])
        let id = dataProvider.viewModel.itemID(for: collectionView.tag)
        realm.saveStates(states, with: id)
    }

}

// MARK: - Interactable
extension ServingsViewController: Interactable {

    func viewDidTap() {
        unblurBackground()
    }
}
