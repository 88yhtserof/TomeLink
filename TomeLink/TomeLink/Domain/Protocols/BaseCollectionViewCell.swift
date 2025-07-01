//
//  BaseCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

protocol BaseCollectionViewCell: AnyObject, ConfigurableView {
    
    static var identifier: String { get }
}

extension BaseCollectionViewCell {
    
    static var identifier: String {
        String(describing: self)
    }
}
