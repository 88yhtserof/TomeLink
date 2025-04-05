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
    
    private let thumbnailView = ThumbnailView()
    private let favoriteButton = FavoriteButton()
    
    private var id: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureConstraints()
        
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
        
        thumbnailView.image = nil
    }

    
    func configure(with value: String) {
//        self.id = value.id
        if let url = URL(string: value) {
            thumbnailView.setImage(with: url)
        }
        favoriteButton.bind(viewModel: FavoriteButtonViewModel(id: UUID().uuidString)) // 임시
    }
}

//MARK: - Configuration
private extension LibraryThumbnailCollectionViewCell {
    
    func configureHierarchy() {
        contentView.addSubviews(thumbnailView, favoriteButton)
    }
    
    func configureConstraints() {
        
        thumbnailView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(thumbnailView.snp.bottom).offset(8)
            make.trailing.equalTo(thumbnailView)
            make.size.equalTo(30)
            make.bottom.equalToSuperview()
        }
    }
}
