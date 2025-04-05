//
//  SeparatorView.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/5/25.
//

import UIKit
import SnapKit

final class SeparatorView: UIView {
    private let lineView = UIView()
    
    var lineColor: UIColor = TomeLinkColor.separator {
        didSet {
            lineView.backgroundColor = lineColor
        }
    }
    
    var lineHeight: CGFloat = 1.0 {
        didSet {
            lineView.snp.updateConstraints { make in
                make.height.equalTo(lineHeight)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLine()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLine() {
        lineView.backgroundColor = lineColor
        addSubview(lineView)
        
        lineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(lineHeight)
        }
    }
}
