//
//  AladinNetworkError.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/9/25.
//

import Foundation

enum AladinNetworkError: LocalizedError {
    case unknown
    case error(String)
    
    var errorDescription: String? {
        var message: String
        
        switch self {
        case .unknown:
            message = "알 수 없는 오류 입니다."
        case .error(let string):
            message = string
        }
        return String(format: "$@\n관리자에게 문의바랍니다.", message)
    }
}
