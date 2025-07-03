//
//  LiveSearchRepository.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/2/25.
//

import Foundation

import RxSwift
import RxCocoa

struct LiveSearchRepository: SearchRepository {
    
    /// Requests search to Kakao Book API
    func requestSearch(keyword: String,
                       page: Int,
                       isConnectedToNetwork: BehaviorRelay<Bool>,
                       isLoading: PublishRelay<Bool>) -> Observable<BookSearch> {
        return Observable.just(keyword)
            .distinctUntilChanged()
            .flatMap { text in
                let response: Observable<BookSearchResponseDTO?> = NetworkRequestingManager.shared
                    .request(api: KakaoNetworkAPI.searchBook(query: text, sort: nil, page: page, size: 20, target: nil))
                    .catch { error in
                        print("Error", error)
                        
                        if let rxError = error as? RxError {
                            switch rxError {
                            case .timeout:
                                isConnectedToNetwork.accept(false)
                                isLoading.accept(false)
                            default:
                                break
                            }
                            
                        }
                        
                        return Single<BookSearchResponseDTO?>.just(nil)
                    }
                    .asObservable()
                
                return response
            }
            .compactMap{ $0?.toDomain() }
    }
}
