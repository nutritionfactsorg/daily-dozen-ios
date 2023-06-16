//  InfoFaqTableViewCell.swift
import Foundation
import UIKit

struct InfoFaqModel {
    let title: String
    let details: NSAttributedString
    var expanded: Bool
    
    init(title: String, details: String, expanded: Bool = false) {
        self.title = title
        self.details = parseLinkedString(details)
        self.expanded = expanded
    }
    
    init(title: String, details: NSAttributedString, expanded: Bool = false) {
        self.title = title
        self.details = details
        self.expanded = expanded
    }
}

final class InfoFaqTableViewCell: UITableViewCell {
    private var expanded: Bool = false
    weak var delegate: ExpandableTableViewCellDelegate?
    
    private let qLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.heleveticaBold17
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let lookBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(.init(systemName: "chevron.down.square.fill"), for: .normal)
        btn.tintColor = ColorManager.style.mainMedium
        return btn
    }()
    
    private let rView: UIView = {
        let view = UIView() // to contain `rLabel`
        view.clipsToBounds = true
        return view
    }()
    
    private let rTView: UITextView = {
        let tview = UITextView()
        tview.font = UIFont.helevetica17
        tview.sizeToFit()
        tview.isScrollEnabled = false
        tview.isEditable = false
        return tview
    }()
    
    private lazy var rViewHeightConstraint = rView.heightAnchor.constraint(
        equalToConstant: 0
    )
    
    var model: InfoFaqModel? {
        didSet {
            qLabel.text = model?.title
            rTView.attributedText = model?.details
            
            expanded = model?.expanded ?? false
            
            // 0.01 ensures button rotation direction 
            lookBtn.transform = expanded ? .init(rotationAngle: .pi - 0.01) : .identity
            rViewHeightConstraint.isActive = !expanded
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        placeContent(in: contentView)
        configureContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func placeContent(in view: UIView) {
        view.addSubview(qLabel)
        view.addSubview(lookBtn)
        view.addSubview(rView)
        
        rView.addSubview(rTView)
        
        qLabel.translatesAutoresizingMaskIntoConstraints = false
        lookBtn.translatesAutoresizingMaskIntoConstraints = false
        rTView.translatesAutoresizingMaskIntoConstraints = false
        rView.translatesAutoresizingMaskIntoConstraints = false
        
        qLabel.setContentHuggingPriority(.required, for: .vertical)
        qLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        qLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        lookBtn.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        rTView.setContentHuggingPriority(.defaultLow, for: .vertical)
        rTView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        let rLabelBottomConstraint = rTView.bottomAnchor.constraint(
            lessThanOrEqualTo: rView.bottomAnchor, constant: -4
        )
        rLabelBottomConstraint.priority = .fittingSizeLevel // Allow "overflow" if needed
        
        NSLayoutConstraint.activate([
            qLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            qLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            
            lookBtn.centerYAnchor.constraint(equalTo: qLabel.centerYAnchor),
            lookBtn.leadingAnchor.constraint(equalTo: qLabel.trailingAnchor, constant: 8),
            lookBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lookBtn.widthAnchor.constraint(equalToConstant: 28),
            lookBtn.heightAnchor.constraint(equalToConstant: 28),
            
            rView.topAnchor.constraint(equalTo: qLabel.bottomAnchor, constant: 4),
            rView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            rView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            rView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -4),
            rViewHeightConstraint,
            
            rTView.topAnchor.constraint(equalTo: rView.topAnchor, constant: 4),
            rTView.leadingAnchor.constraint(equalTo: rView.leadingAnchor),
            rTView.trailingAnchor.constraint(equalTo: rView.trailingAnchor),
            rLabelBottomConstraint
        ])
    }
    
    private func configureContent() {
        selectionStyle = .none
        
        lookBtn.addAction(.init { [weak self] _ in
            guard
                let self = self,
                let tableView = self.superview as? UITableView
            else {
                return
            }
            
            self.expanded = !self.expanded
            
            tableView.performBatchUpdates {
                UIView.animate(
                    withDuration: 0.3, // seconds
                    delay: 0,
                    animations: {
                        // 0.01 ensures button rotation direction 
                        self.lookBtn.transform = self.expanded
                        ? .init(rotationAngle: .pi - 0.01)
                        : .identity
                        self.rViewHeightConstraint.isActive = !self.expanded
                        self.contentView.layoutIfNeeded()
                    }, completion: { completed in
                        // Revert to previous state if animation was interrupted
                        self.expanded = completed ? self.expanded : !self.expanded
                        // 0.01 ensures button rotation direction 
                        self.lookBtn.transform = self.expanded
                        ? .init(rotationAngle: .pi - 0.01)
                        : .identity
                        self.rViewHeightConstraint.isActive = !self.expanded
                        
                        if completed {
                            self.delegate?.expandableTableViewCell(self, expanded: self.expanded)
                        }
                    }
                )
            }
        }, for: .primaryActionTriggered)
    }
    
}
