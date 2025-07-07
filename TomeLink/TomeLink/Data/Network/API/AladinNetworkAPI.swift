//
//  AladinNetworkAPI.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/9/25.
//

import Foundation

enum AladinNetworkAPI: NetworkAPI {
    case itemLookUp(isbn: String)
    
    var url: URL? {
        return urlComponenets?.url
    }
    
    var method: String {
        switch self {
        case .itemLookUp:
            return HTTPMethod.get
        }
    }
    
    var parameters: [URLQueryItem] {
        switch self {
        case .itemLookUp(let isbn):
            return [URLQueryItem(name: "ttbkey", value: AladinNetworkAPI.apiKey), URLQueryItem(name: "ItemIdType", value: "ISBN13"), URLQueryItem(name: "ItemId", value: isbn.components(separatedBy: " ").last ?? "")] // TODO: - 예외 처리
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .itemLookUp:
            return nil
        }
    }
    
    func error<T: Decodable >(_ data: T, statusCode: Int) -> Error {
        guard let errorCode = (data as? AladinNetworkErrorResponse)?.errorCode,
              let message = (data as? AladinNetworkErrorResponse)?.errorMessage else {
            return AladinNetworkError.unknown
        }
        
        print(String(format: "Error: %d\n%@", errorCode, message))
        
        return AladinNetworkError.error(message)
    }
}


private extension AladinNetworkAPI {
    
    static let apiKey: String = AuthorizationManager.aladin.apiKey ?? ""
    
    static let baseURL: String = AuthorizationManager.aladin.url ?? ""
    
    var endPoint: String {
        switch self {
        case .itemLookUp:
            return "ItemLookUp.aspx"
        }
    }
    
    var urlComponenets: URLComponents? {
        let urlString = AladinNetworkAPI.baseURL + endPoint
        var components = URLComponents(string: urlString)
        components?.queryItems = parameters
        return components
    }
}
