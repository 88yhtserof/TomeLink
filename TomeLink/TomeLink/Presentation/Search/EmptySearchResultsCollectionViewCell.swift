//
//  EmptySearchResultsCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/6/25.
//

import UIKit
import SnapKit

final class EmptySearchResultsCollectionViewCell: UICollectionViewCell {
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "검색결과가 없습니다."
        label.font = TomeLinkFont.title
        label.textColor = TomeLinkColor.subtitle
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubviews(messageLabel)
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureConstraints() {
        
        messageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
