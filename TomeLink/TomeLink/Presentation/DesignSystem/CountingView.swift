//
//  CountingView.swift
//  TomeLink
//
//  Created by 임윤휘 on 5/1/25.
//

import UIKit

import SnapKit

final class CountingView: UIView {
    
    private let countLabel = UILabel()
    
    var text: String? {
        get { countLabel.text }
        set { countLabel.text = newValue }
    }

    init() {
        super.init(frame: .zero)
        
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        cornerRadius(frame.width / 2)
    }
    
}

//MARK: - Configuration
private extension CountingView {
    
    func configureView() {
        
        backgroundColor = TomeLinkColor.title
        border(width: 0.4, color: TomeLinkColor.background)
        
        countLabel.text = "0"
        countLabel.textColor = TomeLinkColor.background
        countLabel.font = TomeLinkFont.category
        countLabel.textAlignment = .center
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.5
    }
    
    func configureHierarchy() {
        
        addSubviews(countLabel)
    }
    
    func configureConstraints() {
        
        countLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
    }
}
