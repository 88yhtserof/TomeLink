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
    private let categoryButton = CategoryButton()
    
    // Properties
    var isCategorySelected: Bool {
        get { categoryButton.isSelected }
        set { categoryButton.isSelected = newValue }
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
    func configure(with value: (title: String, isSelected: Bool)) {
        
        categoryButton.title = value.title
    }
}

//MARK: - Configuration
private extension CategoryCollectionViewCell {
    
    func configureView() {
        
        contentView.cornerRadius()
        categoryButton.isUserInteractionEnabled = false
    }
    
    func configureHierarchy() {
        contentView.addSubviews(categoryButton)
    }
    
    func configureConstraints() {
        
        let verticalInset: CGFloat = 4
        let horizontalInset: CGFloat = 2
        
        categoryButton.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(verticalInset)
            make.horizontalEdges.equalToSuperview().inset(horizontalInset)
        }
    }
}
