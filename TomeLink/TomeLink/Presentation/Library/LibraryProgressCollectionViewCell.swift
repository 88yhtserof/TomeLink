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
    
    func configure(with value: String) {
        titleLabel.text = "책 제목"
        subtitleLabel.text = "작가"
        thumbnailView.setImage(with: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5450099%3Ftimestamp%3D20250319144818")!)
        progressLabel.text = "78 %"
        progressBar.progress = Float(23) / Float(140)
    }
}

//MARK: - Configuration
private extension LibraryProgressCollectionViewCell {
    
    func configureView() {
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = TomeLinkColor.title
        
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = TomeLinkColor.subtitle
        
        progressLabel.font = .systemFont(ofSize: 26, weight: .bold)
        progressLabel.textColor = TomeLinkColor.title
        
        
    }
    
    func configureHierarchy() {
        backgroungContainerView.addSubviews(titleLabel, subtitleLabel, thumbnailView, progressLabel, progressBar, pageCountLabel)
        contentView.addSubviews(backgroungContainerView)
    }
    
    func configureConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(thumbnailView.snp.leading).offset(8)
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
        
        progressLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(progressBar.snp.top).offset(-8)
        }
        
        pageCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(progressBar.snp.top).offset(-8)
        }
        
        progressBar.snp.makeConstraints { make in
            make.leading.equalTo(progressLabel)
            make.trailing.equalTo(pageCountLabel)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(4)
        }
    }
}
