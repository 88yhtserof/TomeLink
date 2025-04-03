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
    
    private let thumbnailContainerView = UIView()
    private let thumbnailImageView = UIImageView()
    private let favoriteButton = FavoriteButton()
    
    private var id: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureConstraints()
        configureView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoriteButtonDidSave), name: NSNotification.Name("FavoriteButtonResult"), object: nil)
    }
    
    @objc func favoriteButtonDidSave(_ notification: Notification) {
        guard let id = notification.userInfo?["id"] as? String,
              let result = notification.userInfo?["result"] as? Bool else {
            print("Failed to get result")
            return
        }
        if id == (self.id ?? "") {
            favoriteButton.isSelected = result
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailImageView.image = nil
    }

    
    func configure(with value: String) {
        
//        self.id = value.id
        if let url = URL(string: value) {
            thumbnailImageView.kf.setImage(with: url)
        }
        favoriteButton.bind(viewModel: FavoriteButtonViewModel(id: UUID().uuidString)) // 임시
    }
}

//MARK: - Configuration
private extension LibraryThumbnailCollectionViewCell {
    
    func configureView() {
        
        thumbnailContainerView.shadow()
        
        thumbnailImageView.backgroundColor = TomeLinkColor.imagePlaceholder
        thumbnailImageView.border(width: 0.5, color: TomeLinkColor.shadow)
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
    }
    
    func configureHierarchy() {
        thumbnailContainerView.addSubview(thumbnailImageView)
        contentView.addSubviews(thumbnailContainerView, favoriteButton)
    }
    
    func configureConstraints() {
        
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        thumbnailContainerView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(16)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(6)
            make.trailing.equalTo(thumbnailImageView)
            make.size.equalTo(30)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}
