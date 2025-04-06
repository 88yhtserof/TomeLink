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
    private let separatorView = SeparatorView()
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumnailImageView.image = nil
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
        
        thumnailImageView.contentMode = .scaleAspectFill
        thumnailImageView.cornerRadius(4)
        thumnailImageView.backgroundColor = TomeLinkColor.shadow
        
        titleLabel.text = "title"
        titleLabel.font = TomeLinkFont.title
        titleLabel.textColor = TomeLinkColor.title
        
        authorLabel.text = "author"
        authorLabel.font = TomeLinkFont.subtitle
        authorLabel.textColor = TomeLinkColor.subtitle
        
        publisherLabel.text = "publisher"
        publisherLabel.font = TomeLinkFont.subtitle
        publisherLabel.textColor = TomeLinkColor.subtitle
        
        labelStackView.axis = .vertical
        labelStackView.alignment = .leading
        labelStackView.spacing = 5
        
        separatorView.lineColor = TomeLinkColor.separator2
    }
    
    func configureHierarchy() {
        contentView.addSubviews(thumnailImageView, labelStackView, favoriteButton, separatorView)
    }
    
    func configureConstraints() {
        
        thumnailImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview()
            make.width.equalTo(80)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.top.equalTo(thumnailImageView).inset(8)
            make.leading.equalTo(thumnailImageView.snp.trailing).offset(10)
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-8)
            make.bottom.lessThanOrEqualTo(thumnailImageView).inset(8)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(labelStackView)
            make.size.equalTo(30)
            make.trailing.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(thumnailImageView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(1.0)
            make.bottom.equalToSuperview().inset(8)
        }
    }
}
