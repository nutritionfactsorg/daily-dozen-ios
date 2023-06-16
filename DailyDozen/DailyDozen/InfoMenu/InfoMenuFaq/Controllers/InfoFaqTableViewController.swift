//
//  InfoFaqTableViewController.swift
//  DailyDozen
//
//  Copyright © 2023 Nutritionfacts.org. All rights reserved.
//

import Foundation
import UIKit

final class InfoFaqTableViewController: UITableViewController {
    
    private var faqItems = [InfoFaqModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        
        tableView.separatorInset = .zero
        tableView.register(InfoFaqTableViewCell.self, forCellReuseIdentifier: "cell")
        
        //let headerView = HeaderView()
        let headerView = InfoFaqHeaderView()
        headerView.frame.size = headerView.systemLayoutSizeFitting(
            .init(
                width: tableView.frameLayoutGuide.layoutFrame.width,
                height: 0
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        tableView.tableHeaderView = headerView
        
        loadFaqItems()
    }
    
    private func loadFaqItems() {
        var faqList = [InfoFaqModel]()
        var question = NSLocalizedString("faq_adapt_question", comment: "")
        var response = NSLocalizedString("faq_adapt_response", comment: "")
        faqList.append(InfoFaqModel(title: question, details: response))
        
        question = NSLocalizedString("faq_age_question", comment: "")
        response = NSLocalizedString("faq_age_response.0", comment: "") 
        + "\n\n" + NSLocalizedString("faq_age_response.1", comment: "")
        faqList.append(InfoFaqModel(title: question, details: response))
        
        question = NSLocalizedString("faq_calories_question", comment: "")
        response = NSLocalizedString("faq_calories_response.0", comment: "")
        + "\n\n" + NSLocalizedString("faq_calories_response.1", comment: "")
        + "\n\n" + NSLocalizedString("faq_calories_response.2", comment: "")
        faqList.append(InfoFaqModel(title: question, details: response))
        
        question = NSLocalizedString("faq_mother_question", comment: "")
        response = NSLocalizedString("faq_mother_response", comment: "")
        faqList.append(InfoFaqModel(title: question, details: response))
        
        question = NSLocalizedString("faq_scaling_question", comment: "")
        response = NSLocalizedString("faq_scaling_response", comment: "")
        faqList.append(InfoFaqModel(title: question, details: response))
        
        question = NSLocalizedString("faq_supplements_question", comment: "")
        response = NSLocalizedString("faq_supplements_response", comment: "")
        faqList.append(InfoFaqModel(title: question, details: response))
        
        faqItems = faqList
    }
    
}

extension InfoFaqTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        faqItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? InfoFaqTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.model = faqItems[indexPath.row]
        return cell
    }
}

extension InfoFaqTableViewController: ExpandableTableViewCellDelegate {
    
    func expandableTableViewCell(_ tableViewCell: UITableViewCell, expanded: Bool) {
        guard let indexPath = tableView.indexPath(for: tableViewCell) else {
            return
        }
        
        let item = faqItems[indexPath.row]
        
        faqItems[indexPath.row] = .init(
            title: item.title,
            details: item.details,
            expanded: expanded
        )
    }
}
