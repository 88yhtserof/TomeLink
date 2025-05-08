//
//  CalendarCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/4/25.
//

import UIKit

import Kingfisher
import SnapKit

class CalendarCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static var identifier: String = String(describing: CalendarCollectionViewCell.self)
    
    private let dayLabel = UILabel()
    private let imageView = UIImageView()
    private let countingView = CountingView()
    
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
        
        dayLabel.text = nil
        imageView.image = nil
        countingView.isHidden = true
    }
    
    func configure(with value: (day: Int?, books: [Book]?)) {
        
        guard let day = value.day,
              let books = value.books else {
            dayLabel.text = nil
            imageView.image = nil
            return
        }
        
        dayLabel.text = String(day)
        
        if let urlString = books.first?.thumbnailURL,
           let url = URL(string: urlString) {
            imageView.kf.setImage(with: url)
        }
        
        if books.count > 1 {
            countingView.isHidden = false
            countingView.text = String(books.count)
        }
    }
}

//MARK: - Configuration
private extension CalendarCollectionViewCell {
    
    func configureView() {
        
        dayLabel.textAlignment = .center
        dayLabel.textColor = TomeLinkColor.title
        dayLabel.font = .systemFont(ofSize: 14)
        imageView.contentMode = .scaleToFill
        
        countingView.isHidden = true
    }
    
    func configureHierarchy() {
        
        addSubviews(dayLabel, imageView, countingView)
    }
    
    func configureConstraints() {
        
        dayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
            make.bottom.equalToSuperview().inset(2)
        }
        
        countingView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(4)
            make.size.equalTo(20)
        }
    }
}
