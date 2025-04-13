//
//  NetworkRequestingManager.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/30/25.
//

import Foundation

import RxSwift
import RxCocoa
import XMLCoder

final class NetworkRequestingManager {
    
    static let shared = NetworkRequestingManager()
    
    private init() {}
    
    func request<T: Decodable>(api: NetworkAPI) -> Single<T> {
        return Single<T>.create { observer in
            let task = Task {
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
                task.cancel()
                print("Network Request Disposed")
            }
        }
        .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    // TODO: - 범용적 사용을 위해 리팩토링
    func requestXML<T: Decodable>(api: NetworkAPI, type: T.Type) -> Single<T> {
        return Single<T>.create { observer in
            let task = Task {
                guard let url = api.url else {
                    observer(.failure(NetworkError.invaildURL))
                    return Disposables.create()
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
                    
                    let decoder = XMLDecoder()
                    decoder.shouldProcessNamespaces = true
                    
                    switch httpResponse.statusCode {
                    case 200..<300:
                        // error일 경우 에러 바디로
                        if let errorResponse = try? decoder.decode(AladinNetworkErrorResponse.self, from: data),
                           errorResponse.errorCode != 0
                        {
                            observer(.failure(api.error(errorResponse, statusCode: httpResponse.statusCode)))
                            return Disposables.create()
                        } else if let decoded = try? decoder.decode(T.self, from: data) {
                            observer(.success(decoded))
                        }
                    case 400..<600:
                        observer(.failure(NetworkError.failedRequest))
                        return Disposables.create()
                    default:
                        observer(.failure(NetworkError.unknown))
                        return Disposables.create()
                    }
                    
                } catch {
                    observer(.failure(error))
                    return Disposables.create()
                }
                return Disposables.create()
            }
            
            return Disposables.create {
                task.cancel()
                print("Network Request Disposed")
            }
        }
        .timeout(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
    }
}

