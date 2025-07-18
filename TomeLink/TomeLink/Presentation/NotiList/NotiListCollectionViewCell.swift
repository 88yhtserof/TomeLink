//
//  NotiListCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/1/25.
//

import UIKit

final class NotiListCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    // view
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let dateLabel = UILabel()
    
    private lazy var labelStackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel, dateLabel])
    
    // life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViewHierarchy()
        configureViewConstraints()
        configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // item configuration
    func configure(with item: NotificationItem) {
        titleLabel.text = item.title
        contentLabel.text = item.content
        dateLabel.text = TLDateFormatter.notifiedAt.string(from: item.notifiedAt)
        
        if let type = NotificationUseCase.NotiTopic(rawValue: item.type) {
            imageView.image = UIImage(systemName: type.imageName)
        }
    }
}

//MARK: - Configuration
extension NotiListCollectionViewCell {
    
    func configureView() {
        imageView.image = UIImage(systemName: NotificationUseCase.NotiTopic.all.imageName)
        imageView.tintColor = .tomelinkGray
        
        titleLabel.font = TomeLinkFont.title
        titleLabel.textColor = .tomelinkBlack
        
        contentLabel.font = TomeLinkFont.subtitle
        titleLabel.textColor = .tomelinkBlack
        
        dateLabel.font = TomeLinkFont.subtitle
        dateLabel.textColor = .tomelinkGray
        
        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        labelStackView.distribution = .fillProportionally
    }
    
    func configureViewHierarchy() {
        contentView.addSubviews(imageView, labelStackView)
    }
    
    func configureViewConstraints() {
        
        let vInstet: CGFloat = 16
        let hInstet: CGFloat = 16
        let offset: CGFloat = 8
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.leading.equalToSuperview().inset(hInstet)
            make.top.equalToSuperview().inset(vInstet)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(offset)
            make.trailing.equalToSuperview().inset(hInstet)
            make.verticalEdges.equalToSuperview().inset(vInstet)
        }
    }
}
