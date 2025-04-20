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
    func configure(with value: String) {
        thumnailView.setImage(with: value)
    }
    
}

//MARK: - Configuration
extension ThumbnailCollectionViewCell {
    
    func configureViewHierarchy() {
        contentView.addSubviews(thumnailView)
    }
    
    func configureViewConstraints() {
        
        thumnailView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.width.equalTo(thumnailView.snp.height).multipliedBy(3.0 / 4.3)
        }
    }
    
    func configureViewDetails() {
        
        thumnailView.contentMode = .scaleAspectFit
        thumnailView.backgroundColor = TomeLinkColor.background
    }
}
