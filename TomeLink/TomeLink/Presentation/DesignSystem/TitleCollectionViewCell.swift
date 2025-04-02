//
//  TitleCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/2/25.
//

import UIKit

final class TitleCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static let identifier = String(describing: TitleCollectionViewCell.self)
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with value: String) {
        titleLabel.text = value
    }
}

//MARK: - Configuration
private extension TitleCollectionViewCell {
    
    func configureView() {
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = TomeLinkColor.shadow
        titleLabel.textAlignment = .center
    }
    
    func configureHierarchy() {
        contentView.addSubviews(titleLabel)
    }
    
    func configureConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
