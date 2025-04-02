//
//  BaseSupplementaryView.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

protocol BaseSupplementaryView: AnyObject, ConfigurableView {
    
    static var elementKind: String { get }
}
