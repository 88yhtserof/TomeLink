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
    private var isbn: String?
    
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
        configureNotification()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumnailImageView.image = UIImage(named: "Image_placeholder")
    }
    
    func configure(with value: Book) {
        
        self.isbn = value.isbn
        
        titleLabel.text = value.title
        authorLabel.text = value.authors.joined(separator: ", ")
        publisherLabel.text = value.publisher
        
        let repository = FavoriteRepository()
        let favoriteViewModel = FavoriteButtonViewModel(book: value, repository: repository)
        favoriteButton.bind(viewModel: favoriteViewModel)
        
        if let imageURL = URL(string: value.thumbnailURL) {
            thumnailImageView.kf.setImage(with: imageURL,
                                          placeholder: UIImage(named: "Image_placeholder"))
        }
    }
    
    // Notification
    func configureNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoriteButtonDidSave), name: NSNotification.Name("FavoriteButtonResult"), object: nil)
    }
    
    @objc func favoriteButtonDidSave(_ notification: Notification) {
        guard let id = notification.userInfo?["id"] as? String,
              let result = notification.userInfo?["result"] as? Bool else {
            print("Failed to get result")
            return
        }
        if id == (self.isbn ?? "") {
            favoriteButton.isSelected = result
        }
    }
}

//MARK: - Configuration
private extension BookListCollectionViewCell {
    
    func configureView() {
        
        thumnailImageView.contentMode = .scaleAspectFill
        thumnailImageView.cornerRadius(4)
        thumnailImageView.backgroundColor = TomeLinkColor.shadow
        thumnailImageView.image = UIImage(named: "Image_placeholder")
        
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
