//
//  CalendarDetailCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 5/1/25.
//

import UIKit

import Kingfisher

final class CalendarDetailCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static var identifier = String(describing: BookListCollectionViewCell.self)
    private var isbn: String?
    
    // View
    private let thumnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let publisherLabel = UILabel()
    private lazy var labelStackView = UIStackView(arrangedSubviews: [titleLabel, authorLabel, publisherLabel])
    private let archivedAtLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureConstraints()
        configureView()    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumnailImageView.image = nil
    }
    
    func configure(with valueq: (Date, Book)) {
        
        let (date, book) = valueq
        self.isbn = book.isbn
        
        titleLabel.text = book.title
        authorLabel.text = book.authors.joined(separator: ", ")
        publisherLabel.text = book.publisher
        archivedAtLabel.text = TLDateFormatter.startedAt.string(from: date)
        
        if let imageURL = URL(string: book.thumbnailURL) {
            thumnailImageView.kf.setImage(with: imageURL)
        }
    }
}

//MARK: - Configuration
private extension CalendarDetailCollectionViewCell {
    
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
        
        archivedAtLabel.text = "archivedAt"
        archivedAtLabel.font = TomeLinkFont.subtitle
        archivedAtLabel.textColor = TomeLinkColor.title
        
        labelStackView.axis = .vertical
        labelStackView.alignment = .leading
        labelStackView.spacing = 5
    }
    
    func configureHierarchy() {
        contentView.addSubviews(thumnailImageView, labelStackView, archivedAtLabel)
    }
    
    func configureConstraints() {
        
        let verticalInset: CGFloat = 8
        let height: CGFloat = 150 - (verticalInset * 3)
        
        thumnailImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(verticalInset)
            make.leading.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(height)
            make.bottom.equalToSuperview().inset(verticalInset * 3)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.top.equalTo(thumnailImageView).inset(8)
            make.leading.equalTo(thumnailImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualTo(thumnailImageView).inset(8)
        }
        
        archivedAtLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumnailImageView.snp.trailing).offset(10)
            make.bottom.equalTo(thumnailImageView)
        }
    }
}
