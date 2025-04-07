//
//  PlatformCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/7/25.
//

import UIKit

import SnapKit
import Kingfisher

class PlatformCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static let identifier = String(describing: PlatformCollectionViewCell.self)
    
    // View
    private let logoImageView = UIImageView()
    private let platformLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    // LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViewHierarchy()
        configureViewConstraints()
        configureViewDetails()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with value: String) {
        if let url = URL(string: "") {
            logoImageView.kf.setImage(with: url)
        }
        platformLabel.text = value
    }
}

//MARK: - Configuration
extension PlatformCollectionViewCell {
    
    func configureViewHierarchy() {
        contentView.addSubviews(logoImageView, platformLabel, arrowImageView)
    }
    
    func configureViewConstraints() {
        
        logoImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(24)
        }
        
        platformLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(logoImageView.snp.trailing).offset(10)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(15)
            make.width.height.equalTo(20)
        }
    }
    
    func configureViewDetails() {
        
        contentView.backgroundColor = TomeLinkColor.subbackground
        contentView.cornerRadius(8)
        
        logoImageView.contentMode = .scaleAspectFit
        
        platformLabel.font = .boldSystemFont(ofSize: 14)
        platformLabel.textColor = TomeLinkColor.title
        
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .lightGray
    }
}
