//
//  TweakDetailViewController.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

// MARK: - Builder
class TweakDetailBuilder {
    
    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Parameter itemTypeKey: An item type key string.
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController(itemTypeKey: String) -> TweakDetailViewController {
        
        let storyboard = UIStoryboard(name: "TweakDetailLayout", bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? TweakDetailViewController
            else { fatalError("Did not instantiate `TweakDetailViewController`") }
        
        viewController.setViewModel(itemTypeKey: itemTypeKey)
        
        return viewController
    }
}

// MARK: - Controller
class TweakDetailViewController: UIViewController {
    
    // MARK: - Nested
    private struct Keys {
        static let videos = "VIDEOS"
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var dataProvider: TweakDetailDataProvider!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailsImageView: UIImageView!
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white

        tableView.dataSource = dataProvider
        tableView.delegate = self
        
        if let dataCountType = dataProvider.dataCountType {
            if dataCountType.typeKey.prefix(4) == "doze" {
                // TweakDetailViewController VIDEOS
                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: Keys.videos,
                    style: .done,
                    target: self,
                    action: #selector(barItemPressed)
                )
            }
        }
        
        detailsImageView.image = dataProvider.viewModel.detailsImage
        titleLabel.text = dataProvider.viewModel.itemTitle
    }
    
    // MARK: - Methods
    /// Sets a view model for the current item.
    ///
    /// - Parameter item: The current item name.
    func setViewModel(itemTypeKey: String) {
        dataProvider.viewModel = TweakTextsProvider.shared.getDetails(itemTypeKey: itemTypeKey)
        dataProvider.dataCountType = DataCountType(itemTypeKey: itemTypeKey)
    }
    
    /// Opens the main topic url in the browser.
    @objc private func barItemPressed() {
        UIApplication.shared
            .open(dataProvider.viewModel.topicURL,
                  options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                  completionHandler: nil)
    }
    
    // MARK: - Actions
    /// Updates the tableView for the current unit type.
    ///
    /// - Parameter sender: The button.
    @IBAction private func unitsChanged(_ sender: UIButton) {
        let sectionIndex = TweakDetailSection.activity.rawValue
        guard
            let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
            let currentUnitsType = UnitsType(rawValue: unitsTypePrefStr),
            let indexPaths = tableView.indexPathsForRows(in: tableView.rect(forSection: sectionIndex))
            else { return }
        
        let newUnitsType: UnitsType = currentUnitsType.toggledType
        UserDefaults.standard.set(newUnitsType.rawValue, forKey: SettingsKeys.unitsTypePref)
        let title = newUnitsType.title
        sender.setTitle(title, for: .normal)
        dataProvider.viewModel.unitsType = newUnitsType
        tableView.reloadRows(at: indexPaths, with: .fade)
    }
    
}

// MARK: - UITableViewDelegate
extension TweakDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = TweakDetailSection(rawValue: indexPath.section) else {
            fatalError("There should be a section type")
        }
        
        if sectionType == .description &&
            dataProvider.dataCountType.isTweak {
            let x = CGFloat(0.0)
            let y = CGFloat(0.0)
            let height = CGFloat(0.0)
            let width = tableView.contentSize.width * 0.70
            let label = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
            label.numberOfLines = 0 // allows label to have as many lines as needed
            
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            let font = UIFont(name: "Helvetica Neue", size: 14.0)
            label.font = font
            
            let typeKey = dataProvider.dataCountType.typeKey
            let descriptionParagraph = TweakTextsProvider.shared
                .getDetails(itemTypeKey: typeKey)
                .descriptionParagraph(index: indexPath.row)
            
            label.text  = "\n\(descriptionParagraph)\n margin\n"
            label.sizeToFit()
            //print("indexPath: \(indexPath)")
            //print("\(label.fs_width) w x \(label.fs_height) h")
            return label.fs_height
        }
        
        return sectionType.rowHeight // :!!!:UNITS_VISIBILITY:
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard 
            let sectionType = TweakDetailSection(rawValue: section),
            let dataCountType = dataProvider.dataCountType
            else {
                fatalError("There should be a tweak section header height")
        }
        return sectionType.headerHeight(itemTypeKey: dataCountType.typeKey)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard 
            let sectionType = TweakDetailSection(rawValue: section),
            let dataCountType = dataProvider.dataCountType 
            else {
                fatalError("There should be a tweak section type")
        }
        return sectionType.headerTweaksView(itemTypeKey: dataCountType.typeKey)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
