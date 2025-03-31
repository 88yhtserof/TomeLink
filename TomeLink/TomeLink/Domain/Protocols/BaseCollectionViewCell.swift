//
//  BaseCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

protocol BaseCollectionViewCell: AnyObject {
    
    associatedtype Element
    
    var identifier: String { get }
    
    func configure(with: Element)
}
