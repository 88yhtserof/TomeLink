//
//  EmptyCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/6/25.
//

import UIKit
import SnapKit

final class EmptyCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static let identifier = String(describing: EmptyCollectionViewCell.self)
    
    private let messageLabel: UILabel = {
        let label = UILabel()
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
    
    func configure(with value: String) {
        messageLabel.text = value
    }
}

//MARK: - Configuration
private extension EmptyCollectionViewCell {
    
    func configureConstraints() {
        
        messageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
