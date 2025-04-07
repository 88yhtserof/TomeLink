//
//  ThumbnailCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/7/25.
//

import UIKit

import SnapKit
import Kingfisher

final class ThumbnailCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static var identifier = String(describing: ThumbnailCollectionViewCell.self)
    
    // View
    private let thumnailView = ThumbnailView()
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumnailView.image = UIImage()
    }
    
    // Feature
    func configure(with value: URL?) {
        if let url = value {
            thumnailView.setImage(with: url)
        }
    }
    
}

//MARK: - Configuration
extension ThumbnailCollectionViewCell {
    
    func configureViewHierarchy() {
        contentView.addSubviews(thumnailView)
    }
    
    func configureViewConstraints() {
        
        thumnailView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
    }
    
    func configureViewDetails() {
        
        thumnailView.contentMode = .scaleAspectFill
        thumnailView.backgroundColor = TomeLinkColor.background
    }
}
