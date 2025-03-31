//
//  ConfigurableView.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

protocol ConfigurableView {
    
    associatedtype Element
    
    func configure(with: Element)
}
