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
        imageView.contentMode = .scaleAspectFill
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(imageView)
        
        // SnapKit을 사용한 제약 설정
        dayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.trailing.bottom.equalToSuperview().inset(5)
            make.height.equalTo(imageView.snp.width) // 이미지 비율 유지
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(day: Int?, imageUrl: String?) {
        dayLabel.text = day != nil ? "\(day!)" : ""
        
        guard let imageUrl else { return }
        let imageURLString = ImageResizingManager.resizingImage(for: imageUrl)
        
        if let url = URL(string: imageURLString) {
            
            
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url,
                                  placeholder: UIImage(named: "Image_placeholder")) { result in
                switch result {
                case .success:
                    print("Image loaded successfully")
                case .failure(let error):
                    print("Failed to load image: \(error)")
                }
            }
        } else {
            imageView.image = UIImage(named: "Image_placeholder")
        }
    }
}
