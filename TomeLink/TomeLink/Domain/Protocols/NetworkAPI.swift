//
//  NetworkAPI.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/29/25.
//

import Foundation

protocol NetworkAPI {
    
    var url: URL? { get }
    var method: String { get }
    var parameters: [URLQueryItem] { get }
    var headers: [String: String]? { get }
    
    // Return the error with the error description for configuring the alert.
    func error<T: Decodable>(_ data: T, statusCode: Int) -> Error
}
