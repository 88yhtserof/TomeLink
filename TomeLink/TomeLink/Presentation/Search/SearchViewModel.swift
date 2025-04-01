//
//  SearchViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

import RxSwift
import RxCocoa

final class SearchViewModel: BaseViewModel {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let searchKeyword: ControlProperty<String>
        let tapSearchButton: ControlEvent<Void>
        let deleteRecentSearch: PublishRelay<String>
    }
    
    struct Output {
        let recentResearches: Driver<[String]>
        let bookSearches: Driver<[Book]>
    }
    
    func transform(input: Input) -> Output {
        
        let recentResearches = BehaviorRelay<[String]>(value: [])
        let searchResults = PublishRelay<[Book]>()
        
        RecentResultsManager.elements
            .bind(to: recentResearches)
            .disposed(by: disposeBag)
        
        input.deleteRecentSearch
            .map { RecentResultsManager.remove(of: $0) }
            .subscribe()
            .disposed(by: disposeBag)
        
        
        let bookSearchResponse = input.tapSearchButton
            .withLatestFrom(input.searchKeyword)
            .distinctUntilChanged()
            .flatMap { text in
                return NetworkRequestingManager.shared
                    .request(api: KakaoNetworkAPI.searchBook(query: text, sort: nil, page: 1, size: 20, target: nil))
                    .catch { error in
                        print("Error", error)
                        return Single<BookSearchResponseDTO?>.just(nil)
                    }
            }
            .compactMap{ $0 }
        
        bookSearchResponse
            .map { $0.toDomain().books }
            .bind(to: searchResults)
            .disposed(by: disposeBag)
        
        
        return Output(recentResearches: recentResearches.asDriver(),
                      bookSearches: searchResults.asDriver(onErrorJustReturn: []))
    }
}
