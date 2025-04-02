//
//  RecentResultProtocol.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/1/25.
//

import Foundation

protocol RecentResultsProtocol {
    
    associatedtype Element
    
    var elements: [Element] { get }
    
    func save(_ element: Element)
    func remove(of element: Element)
    func removeAll()
}
