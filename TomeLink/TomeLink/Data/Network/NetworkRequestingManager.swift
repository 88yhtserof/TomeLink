//
//  NetworkRequestingManager.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/30/25.
//

import Foundation

import RxSwift
import RxCocoa

final class NetworkRequestingManager {
    
    static let shared = NetworkRequestingManager()
    
    private init() {}
    
    func request<T: Decodable>(api: NetworkAPI) async throws -> T {
        
        guard let url = api.url else {
            throw NetworkError.invaildURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = api.method
        request.allHTTPHeaderFields = api.headers
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.failedRequest
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            print("Success")
            return try JSONDecoder().decode(T.self, from: data)
        case 400..<600:
            throw api.error(data, statusCode: httpResponse.statusCode)
        default:
            throw NetworkError.unknown
        }
    }
}
