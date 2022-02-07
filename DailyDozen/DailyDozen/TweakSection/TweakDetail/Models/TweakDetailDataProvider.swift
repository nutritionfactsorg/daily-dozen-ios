//
//  TweakDetailDataProvider.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import UIKit

class TweakDetailDataProvider: NSObject, UITableViewDataSource {
    
    // MARK: - Nested
    private struct Strings {
        static let activityCellID = "tweakDetailActivityCell"
        static let descriptionCellID = "tweakDetailDescriptionCell"
    }
    
    var viewModel: TweakDetailViewModel!
    var dataCountType: DataCountType!
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = TweakDetailSections(rawValue: section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {
        case .activity:
            return viewModel.activityCount
        case .explanation:
            return 1
        }
    }
    
    // Row Cell At Index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = TweakDetailSections(rawValue: indexPath.section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {
            
        case .activity:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: Strings.activityCellID) as? TweakDetailActivityCell
                else { return UITableViewCell() }
            
            cell.configure(
                title: viewModel.activity(index: indexPath.row)
            )
            return cell
            
        case .explanation:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: Strings.descriptionCellID) as? TweakDetailDescriptionCell
                else { return UITableViewCell() }
            let descriptionParagraph = viewModel.descriptionParagraph(index: indexPath.row)
            
            cell.configure(title: descriptionParagraph)
            
            return cell
        }
    }
}
