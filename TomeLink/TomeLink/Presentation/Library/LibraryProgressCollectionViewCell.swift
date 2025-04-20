//
//  LibraryProgressCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/3/25.
//

import UIKit

import SnapKit
import Kingfisher

final class LibraryProgressCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static let identifier = String(describing: LibraryProgressCollectionViewCell.self)
    
    private let backgroungContainerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let pageLabel = UILabel()
    private let progressLabel = UILabel()
    private let thumbnailView = ThumbnailView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailView.image = nil
    }
    
    private let pageCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = .lightGray
        progressView.progressTintColor = .black
        return progressView
    }()
    
    func configure(with value: Reading) {
        
        let book = value.book
        titleLabel.text = book.title
        subtitleLabel.text = book.authors.joined(separator: ", ")
        pageLabel.text = "\(value.currentPage) / \(value.pageCount)"
        
        if let url = URL(string: book.thumbnailURL) {
            thumbnailView.setImage(with: url)
        }
        
        progressLabel.text = String(format: "%0.f%%", value.progress)
        progressBar.progress = Float(value.progress / 100.0)
    }
}

//MARK: - Configuration
private extension LibraryProgressCollectionViewCell {
    
    func configureView() {
        
        backgroungContainerView.backgroundColor = TomeLinkColor.imagePlaceholder
        backgroungContainerView.border(color: TomeLinkColor.shadow)
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = TomeLinkColor.title
        titleLabel.numberOfLines = 2
        
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = TomeLinkColor.subtitle
        
        progressLabel.font = .systemFont(ofSize: 30, weight: .bold)
        progressLabel.textColor = TomeLinkColor.title
        
        pageLabel.font = .systemFont(ofSize: 13, weight: .light)
        pageLabel.textColor = TomeLinkColor.title
    }
    
    func configureHierarchy() {
        backgroungContainerView.addSubviews(titleLabel, subtitleLabel, thumbnailView, pageLabel, progressLabel, progressBar)
        contentView.addSubviews(backgroungContainerView)
    }
    
    func configureConstraints() {
        
        backgroungContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(thumbnailView.snp.leading).offset(-8)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(titleLabel)
        }
        
        thumbnailView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
            make.width.equalTo(100)
            make.height.equalTo(140)
        }
        
        pageLabel.snp.makeConstraints { make in
            make.bottom.equalTo(progressLabel)
            make.trailing.equalTo(thumbnailView).inset(8)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.greaterThanOrEqualTo(thumbnailView)
        }
        
        progressBar.snp.makeConstraints { make in
            make.top.equalTo(progressLabel.snp.bottom).offset(8)
            make.leading.equalTo(progressLabel)
            make.trailing.equalTo(thumbnailView)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(4)
        }
    }
}
