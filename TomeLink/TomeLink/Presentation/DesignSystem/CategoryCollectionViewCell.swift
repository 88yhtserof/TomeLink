//
//  CategoryCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/4/25.
//

import UIKit
import SnapKit

class CategoryCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static let identifier = String(describing: CategoryCollectionViewCell.self)
    
    // Views
    private let categoryBackgroundView = UIView()
    private let categoryLabel = UILabel()
    
    // Properties
    override var isSelected: Bool {
        willSet {
            if newValue != isSelected {
                updateState(newValue ? .selected : .normal)
            }
        }
    }
    
    // LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Feature
    func configure(with value: String) {
        
        categoryLabel.text = value
    }
}

//MARK: - Configuration
private extension CategoryCollectionViewCell {
    
    func configureView() {
        
        contentView.border(color: TomeLinkColor.title)
        
        categoryLabel.font = TomeLinkFont.category
        categoryLabel.textColor = TomeLinkColor.title
        
    }
    
    func configureHierarchy() {
        contentView.addSubviews(categoryLabel)
    }
    
    func configureConstraints() {
        
        let verticalInset: CGFloat = 2
        let horizontalInset: CGFloat = 10
        
        categoryLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(verticalInset)
            make.horizontalEdges.equalToSuperview().inset(horizontalInset)
        }
    }
}

//MARK: - Selected State
private extension CategoryCollectionViewCell {
    
    enum State {
        case normal
        case selected
    }
    
    func updateState(_ state: State) {
        
        switch state {
        case .normal:
            categoryLabel.textColor = TomeLinkColor.title
            contentView.backgroundColor = TomeLinkColor.background
        case .selected:
            categoryLabel.textColor = TomeLinkColor.background
            contentView.backgroundColor = TomeLinkColor.title
        }
    }
}
