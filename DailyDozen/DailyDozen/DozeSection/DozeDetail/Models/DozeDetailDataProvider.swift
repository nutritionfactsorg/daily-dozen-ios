//
//  DozeDetailDataProvider.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import UIKit

class DozeDetailDataProvider: NSObject, UITableViewDataSource {
    
    // MARK: - Nested
    private struct Strings {
        static let sizeCellID = "dozeDetailSizeCell"
        static let typeCellID = "dozeDetailTypeCell"
    }
    
    var viewModel: DozeDetailViewModel!
    var dataCountType: DataCountType!
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = DozeDetailSections(rawValue: section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {
        case .amount:
            return viewModel.amountCount
        case .example:
            return viewModel.exampleCount
        }
    }
    
    // Row Cell At Index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = DozeDetailSections(rawValue: indexPath.section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {
            
        case .amount:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: Strings.sizeCellID) as? DozeDetailSizeCell
                else { return UITableViewCell() }
            
            cell.configure(
                title: viewModel.sizeDescription(index: indexPath.row)
            )
            return cell
            
        case .example:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: Strings.typeCellID) as? DozeDetailTypeCell
                else { return UITableViewCell() }
            let typeData = viewModel.typeData(index: indexPath.row)
            
            if dataCountType.isTweak {
                cell.configure(title: typeData.name)
            } else {
                cell.configure(
                    title: typeData.name,
                    useLink: typeData.hasLink,
                    tag: indexPath.row
                )
            }
            
            return cell
        }
    }
}
