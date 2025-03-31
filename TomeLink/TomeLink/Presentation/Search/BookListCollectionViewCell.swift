//
//  BookListCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import UIKit

import Kingfisher

final class BookListCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static var identifier = String(describing: BookListCollectionViewCell.self)
    
    // View
    private let thumnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let publisherLabel = UILabel()
    private lazy var labelStackView = UIStackView(arrangedSubviews: [titleLabel, authorLabel, publisherLabel])
    private let favoriteButton = FavoriteButton()
    
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
    
    func configure(with value: Book) {
        
        titleLabel.text = value.title
        authorLabel.text = value.authors.joined(separator: ", ")
        publisherLabel.text = value.publisher
        
        let favoriteViewModel = FavoriteButtonViewModel(id: value.isbn)
        favoriteButton.bind(viewModel: favoriteViewModel)
        
        if let imageURL = value.thumbnailURL {
            thumnailImageView.kf.setImage(with: imageURL)
        }
    }
}

//MARK: - Configuration
private extension BookListCollectionViewCell {
    
    func configureView() {
        thumnailImageView.contentMode = .scaleAspectFit
        thumnailImageView.cornerRadius()
        thumnailImageView.backgroundColor = TomeLinkColor.shadow
        
        titleLabel.text = "title"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = TomeLinkColor.title
        
        authorLabel.text = "author"
        authorLabel.font = .systemFont(ofSize: 14, weight: .regular)
        authorLabel.textColor = TomeLinkColor.subtitle
        
        publisherLabel.text = "publisher"
        publisherLabel.font = .systemFont(ofSize: 14, weight: .regular)
        publisherLabel.textColor = TomeLinkColor.subtitle
        
        labelStackView.axis = .vertical
        labelStackView.alignment = .leading
        labelStackView.spacing = 5
    }
    
    func configureHierarchy() {
        contentView.addSubviews(thumnailImageView, labelStackView, favoriteButton)
    }
    
    func configureConstraints() {
        
        thumnailImageView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview().inset(10)
            make.width.equalTo(80)
            make.height.equalTo(110)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.top.equalTo(thumnailImageView)
            make.leading.equalTo(thumnailImageView.snp.trailing).offset(10)
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-8)
            make.bottom.lessThanOrEqualTo(thumnailImageView)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(thumnailImageView)
            make.size.equalTo(30)
            make.trailing.equalToSuperview().inset(10)
        }
    }
}
