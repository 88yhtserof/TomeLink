//
//  SearchUseCase.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/2/25.
//

import Foundation

import RxSwift
import RxCocoa

struct SearchUseCase {
    private let searchRepository: SearchRepository

    init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }

    func search(
        keyword: String,
        page: Int,
        isConnectedToNetwork: BehaviorRelay<Bool>,
        isLoading: PublishRelay<Bool>
    ) -> Observable<BookSearch> {
        return searchRepository.requestSearch(
            keyword: keyword,
            page: page,
            isConnectedToNetwork: isConnectedToNetwork,
            isLoading: isLoading
        )
    }
}

