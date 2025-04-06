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
        let willDisplayCell: Observable<IndexPath>
        let selectRecentSearchesItem: PublishRelay<String>
        let selectSearchResultItem: PublishRelay<Book>
        
        let searchKeyword: ControlProperty<String>
        let tapSearchButton: ControlEvent<Void>
        let tapSearchCancelButton: ControlEvent<Void>
    }
    
    struct Output {
        let recentResearches: Driver<[String]>
        let bookSearches: Driver<[Book]>
        let paginationBookSearches: Driver<[Book]>
        let isLoading: Driver<Bool>
    }
    
    private var searchKeyword: String?
    private var page: Int = 1
    private var isEnd: Bool = true
    private var searchResults: [Book] = []
    
    func transform(input: Input) -> Output {
        
        let recentResearches = BehaviorRelay<[String]>(value: [])
        let searchResults = PublishRelay<[Book]>()
        let paginationBookSearches = PublishRelay<[Book]>()
        let isLoading = PublishRelay<Bool>()
        
        // update recent researches
        
        RecentResultsManager.elements
            .bind(to: recentResearches)
            .disposed(by: disposeBag)
        
        input.tapSearchCancelButton
            .withUnretained(self)
            .map { owner, _ in
                owner.searchResults = []
            }
            .withLatestFrom(RecentResultsManager.elements)
            .bind(to: recentResearches)
            .disposed(by: disposeBag)
        
        // update search results
        let searchByButton: Observable<String> = input.tapSearchButton
            .withLatestFrom(input.searchKeyword)
            .withUnretained(self)
            .map { owner, keyword in
                owner.page = 1
                owner.searchResults = []
                return keyword
            }
        
        let pagination: Observable<String> = input.willDisplayCell
            .withUnretained(self)
            .filter { (owner, indexPath) in
                return !owner.isEnd && (owner.searchResults.count - 1) == indexPath.item
            }
            .compactMap {(owner, value) in
                if let keyword = owner.searchKeyword {
                    owner.page += 1
                    return keyword
                } else {
                    return nil
                }
            }
        
        let bookSearchResponse = Observable.of(searchByButton, pagination)
            .merge()
            .withUnretained(self)
            .flatMap { owner, keyword in
                owner.searchKeyword = keyword
                isLoading.accept(true)
                return owner.requestSearch(keyword: keyword)
            }
        
        bookSearchResponse
            .withUnretained(self)
            .map { owner, response in
                isLoading.accept(false)
                owner.isEnd = response.meta.isEnd
                
                let books = response.toDomain().books
                owner.searchResults.append(contentsOf: books)
                
                return owner.searchResults
            }
            .bind(with: self) { owner, list in
                if owner.page == 1 {
                    searchResults.accept(list)
                } else {
                    paginationBookSearches.accept(list)
                }
            }
            .disposed(by: disposeBag)
        
        
        // save recent research
        
        input.tapSearchButton
            .withLatestFrom(input.searchKeyword)
            .bind { text in
                RecentResultsManager.save(text)
            }
            .disposed(by: disposeBag)
        
        
        // select item
        
        input.selectRecentSearchesItem
            .withUnretained(self)
            .flatMap { owner, keyword in
                owner.searchKeyword = keyword
                isLoading.accept(true)
                RecentResultsManager.save(keyword)
                return owner.requestSearch(keyword: keyword)
            }
            .withUnretained(self)
            .map { owner, response in
                isLoading.accept(false)
                owner.isEnd = response.meta.isEnd
                
                let books = response.toDomain().books
                owner.searchResults.append(contentsOf: books)
                
                return owner.searchResults
            }
            .bind(to: searchResults)
            .disposed(by: disposeBag)
        
        return Output(recentResearches: recentResearches.asDriver(),
                      bookSearches: searchResults.asDriver(onErrorJustReturn: []),
                      paginationBookSearches: paginationBookSearches.asDriver(onErrorJustReturn: []),
                      isLoading: isLoading.asDriver(onErrorJustReturn: false))
    }
}

//MARK: - Feature
private extension SearchViewModel {
    
    /// Requests search to Kakao Book API
    func requestSearch(keyword: String) -> Observable<BookSearchResponseDTO> {
        return Observable.just(keyword)
            .distinctUntilChanged()
            .withUnretained(self)
            .flatMap { owner, text in
                return NetworkRequestingManager.shared
                    .request(api: KakaoNetworkAPI.searchBook(query: text, sort: nil, page: owner.page, size: 20, target: nil))
                    .catch { error in
                        print("Error", error)
                        return Single<BookSearchResponseDTO?>.just(nil)
                    }
            }
            .compactMap{ $0 }
    }
}
