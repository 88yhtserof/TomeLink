//
//  BookInfoCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/7/25.
//

import UIKit

import SnapKit

final class BookInfoCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static let identifier = String(describing: BookInfoCollectionViewCell.self)
    
    // View
    private let titleLabel = UILabel()
    private let authorsLabel = UILabel()
    private let publisherLabel = UILabel()
    private let contentsLabel = UILabel()
    
    // LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViewHierarchy()
        configureViewConstraints()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Feature
    func configure(with value: Book) {
        
        titleLabel.text = value.title
        authorsLabel.text = value.authors.joined(separator: ", ")
        publisherLabel.text = value.publisher
        contentsLabel.text = value.contents
    }
}

//MARK: - Configuration
extension BookInfoCollectionViewCell {
    
    func configureView() {
        
        titleLabel.font = TomeLinkFont.title
        titleLabel.textColor = TomeLinkColor.title
        
        authorsLabel.font = TomeLinkFont.subtitle
        authorsLabel.textColor = TomeLinkColor.subtitle
        
        publisherLabel.font = TomeLinkFont.subtitle
        publisherLabel.textColor = TomeLinkColor.title
        
        contentsLabel.font = TomeLinkFont.contents
        contentsLabel.textColor = TomeLinkColor.title
        contentsLabel.numberOfLines = 0
    }
    
    func configureViewHierarchy() {
        contentView.addSubviews(titleLabel, authorsLabel, publisherLabel, contentsLabel)
    }
    
    func configureViewConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(28)
        }
        
        authorsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        
        publisherLabel.snp.makeConstraints { make in
            make.top.equalTo(authorsLabel.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(20)
        }
        
        contentsLabel.snp.makeConstraints { make in
            make.top.equalTo(publisherLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
