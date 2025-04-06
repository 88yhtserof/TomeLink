//
//  LoadingView.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/5/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class LoadingView: UIView {
    
    fileprivate let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = TomeLinkColor.background.withAlphaComponent(0.5)
        
        addSubviews(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: LoadingView {
    
    var showLoading: Binder<Bool> {
        return Binder(base) { base, isLoading in
            if isLoading {
                base.loadingIndicator.startAnimating()
            } else {
                base.loadingIndicator.stopAnimating()
            }
            base.isHidden = !isLoading
        }
    }
}
