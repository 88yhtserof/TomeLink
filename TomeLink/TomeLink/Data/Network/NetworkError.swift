//
//  NetworkError.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/30/25.
//

import Foundation

enum NetworkError: Error {
    case invaildURL
    case couldNotFindData
    case failedRequest
    case failedDecoding
    case unknown
}
