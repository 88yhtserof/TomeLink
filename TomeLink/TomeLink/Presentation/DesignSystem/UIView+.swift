//
//  UIView+.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        views.forEach{ addSubview($0) }
    }
    
    func cornerRadius(_ radius: CGFloat = 10.0) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    func border(width: CGFloat = 1.0, color: UIColor = .black) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
    
    func shadow(opacity: Float = 0.6, radius: CGFloat = 2.5, offset: CGSize = CGSize(width: 0, height: 6)) {
        layer.shadowColor = TomeLinkColor.shadow.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
    }
}
