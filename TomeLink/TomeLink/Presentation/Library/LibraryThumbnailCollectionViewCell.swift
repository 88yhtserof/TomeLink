//
//  LibraryThumbnailCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/2/25.
//

import UIKit

import SnapKit
import Kingfisher

final class LibraryThumbnailCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static let identifier = String(describing: LibraryThumbnailCollectionViewCell.self)
    
    private let thumbnailImageView = UIImageView()
    
    private var id: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureConstraints()
        configureView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoriteButtonDidSave), name: NSNotification.Name("FavoriteButtonResult"), object: nil)
    }
    
    @objc func favoriteButtonDidSave(_ notification: Notification) {
//        guard let id = notification.userInfo?["id"] as? String,
//              let result = notification.userInfo?["result"] as? Bool else {
//            print("Failed to get result")
//            return
//        }
//        if id == (self.id ?? "") {
//            favoriteButton.isSelected = result
//        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        
    }
    
    func configure(with value: String) {
        
//        self.id = value.id
        let str = "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5450099%3Ftimestamp%3D20250319144818"
        if let url = URL(string: str) {
            thumbnailImageView.kf.setImage(with: url)
        }
    }
}

//MARK: - Configuration
private extension LibraryThumbnailCollectionViewCell {
    
    func configureView() {
        thumbnailImageView.backgroundColor = TomeLinkColor.imagePlaceholder
        thumbnailImageView.border(width: 0.5, color: TomeLinkColor.shadow)
        thumbnailImageView.contentMode = .scaleAspectFit
    }
    
    func configureHierarchy() {
        contentView.addSubviews(thumbnailImageView)
    }
    
    func configureConstraints() {
        
        print(frame.width, contentView.frame.width, bounds.size.width)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalTo(contentView.snp.width)
        }
    }
}
