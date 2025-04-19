//
//  RepositoryError.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/19/25.
//

import Foundation

enum RepositoryError: Error {
    case failedToFetchData
    
}

extension RepositoryError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .failedToFetchData:
            return "데이터를 불러오는데 실패했습니다.\n관리자에게 문의 바랍니다."
        }
    }
}
