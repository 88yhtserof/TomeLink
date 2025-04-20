//
//  CalendarCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/4/25.
//

import UIKit

import Kingfisher
import SnapKit

// 커스텀 셀 클래스
class CalendarCollectionViewCell: UICollectionViewCell {
    private let dayLabel = UILabel()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        dayLabel.textAlignment = .center
        dayLabel.textColor = TomeLinkColor.title
        dayLabel.font = .systemFont(ofSize: 14)
        imageView.contentMode = .scaleToFill
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(imageView)
        
        dayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
            make.bottom.equalToSuperview().inset(2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(day: Int?, book: Book?) {
        dayLabel.text = day != nil ? "\(day!)" : ""
        
        if let urlString = book?.thumbnailURL, let url = URL(string: urlString) {
            
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = nil
        }
    }
}
