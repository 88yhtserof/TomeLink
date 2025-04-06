//
//  RecentSearchesCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/6/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class RecentSearchesCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static let identifier = String(describing: RecentSearchesCollectionViewCell.self)
    
    // Views
    private let backgroundBorderView = UIView()
    private let textLabel = UILabel()
    private let deleteButton = UIButton()
    
    // Properties
    private var disposeBag = DisposeBag()
    
    // LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    // Feature
    func configure(with value: String) {
        textLabel.text = value
        deleteButton.accessibilityHint = value
        
        bind()
    }
    
    // Binding
    private func bind() {
        
        deleteButton.rx.tap
            .withUnretained(self)
            .compactMap{ owner, _ in owner.textLabel.text }
            .bind { text in
                RecentResultsManager.remove(of: text)
            }
            .disposed(by: disposeBag)
    }
}

private extension RecentSearchesCollectionViewCell {
    
    func configureView() {
        backgroundView = UIView()
        selectedBackgroundView = UIView()
        
        backgroundBorderView.backgroundColor = TomeLinkColor.background
        backgroundBorderView.cornerRadius(4)
        backgroundBorderView.border()
        
        textLabel.numberOfLines = 1
        textLabel.font = TomeLinkFont.recentSearches
        textLabel.textColor = TomeLinkColor.title
        
        let deleteImage = UIImage(systemName: "xmark.circle.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 10))
        var config = UIButton.Configuration.plain()
        config.image = deleteImage
        config.baseForegroundColor = TomeLinkColor.buttonBackground
        deleteButton.configuration = config
        deleteButton.accessibilityLabel = "제거"
    }
    
    func configureHierarchy() {
        backgroundBorderView.addSubviews(textLabel, deleteButton)
        contentView.addSubviews(backgroundBorderView)
    }
    
    func configureConstraints() {
        
        backgroundBorderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(200)
            make.verticalEdges.leading.equalToSuperview().inset(6)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(25)
            make.centerY.equalTo(textLabel)
            make.leading.equalTo(textLabel.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(6)
        }
    }
}
