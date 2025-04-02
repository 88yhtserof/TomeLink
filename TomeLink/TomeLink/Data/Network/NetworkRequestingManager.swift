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
    
    func request<T: Decodable>(api: NetworkAPI) -> Single<T> {
        return Single<T>.create { observer in
            Task {
                guard let url = api.url else {
                    throw NetworkError.invaildURL
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = api.method
                request.allHTTPHeaderFields = api.headers
                
                do {
                    let (data, response) = try await URLSession.shared.data(for: request)
                    guard let httpResponse = response as? HTTPURLResponse else {
                        observer(.failure(NetworkError.failedRequest))
                        return Disposables.create()
                    }
                    
                    switch httpResponse.statusCode {
                    case 200..<300:
                        print("Success")
                        let decoded = try JSONDecoder().decode(T.self, from: data)
                        observer(.success(decoded))
                        return Disposables.create()
                    case 400..<600:
                        observer(.failure(api.error(data, statusCode: httpResponse.statusCode)))
                        return Disposables.create()
                    default:
                        observer(.failure(NetworkError.unknown))
                        return Disposables.create()
                    }
                } catch {
                    observer(.failure(error))
                    return Disposables.create()
                }
            }
            
            return Disposables.create {
                print("Network Request Disposed")
            }
        }
    }
}

