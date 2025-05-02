//
//  LibraryCalendarCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/4/25.
//

import UIKit

import SnapKit
import Kingfisher

class LibraryCalendarCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static let identifier = String(describing: CategoryCollectionViewCell.self)
    
    // Views
    let calendarView = CalendarView()
    
    // Properties
    
    // LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Feature
    func configure(with value: [Archive]) {
        
        let calendarViewModel = CalendarViewModel(archives: value)
        calendarView.bind(calendarViewModel)
    }
}

//MARK: - Configuration
private extension LibraryCalendarCollectionViewCell {
    
    func configureHierarchy() {
        contentView.addSubviews(calendarView)
    }
    
    func configureConstraints() {
        
        calendarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
