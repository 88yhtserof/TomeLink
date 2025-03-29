//
//  KakaoNetworkAPI.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/30/25.
//

import Foundation

enum KakaoNetworkAPI: NetworkAPI {
    case searchBook(query: String, sort: String, page: Int, size: Int, target: String)
    
    var url: URL? {
        return URL(string: KakaoNetworkAPI.baseURL + endPoint)
    }
    
    var method: String {
        switch self {
        case .searchBook:
            return HTTPMethod.get
        }
    }
    
    var parameters: [URLQueryItem] {
        switch self {
        case .searchBook(let query, let sort, let page, let size, let target):
            return [URLQueryItem(name: "query", value: query),
                    URLQueryItem(name: "sort", value: sort),
                    URLQueryItem(name: "page", value: String(page)),
                    URLQueryItem(name: "size", value: String(size)),
                    URLQueryItem(name: "target", value: target)]
        }
    }
    
    var headers: [String : String]? {
        
        let header = ["Authorization": KakaoNetworkAPI.apiKey ]
        
        switch self {
        case .searchBook:
            return header
        }
    }
    
    func error<T: Decodable >(_ data: T, statusCode: Int) -> Error {
        guard let errorType = (data as? KakaoNetworkErrorResponse)?.errorType,
              let message = (data as? KakaoNetworkErrorResponse)?.errorType else {
            return KakaoNetworkError.unknown(statusCode: statusCode)
        }
        
        print(String(format: "Error: %d%@\n%@", statusCode, errorType, message))
        
        return KakaoNetworkError(statusCode: statusCode)
    }
}


private extension KakaoNetworkAPI {
    
    static let apiKey: String = AuthorizationManager.kakao.apiKey ?? ""
    
    static let baseURL: String = AuthorizationManager.kakao.url ?? ""
    
    var endPoint: String {
        switch self {
        case .searchBook:
            return "search/book"
        }
    }
    
}
