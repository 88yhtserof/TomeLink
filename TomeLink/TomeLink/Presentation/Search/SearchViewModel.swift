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
        let deleteRecentSearch: PublishRelay<String>
    }
    
    struct Output {
        let recentResearches: Driver<[String]>
        let bookSearches: Driver<[Book]>
        let paginationBookSearches: Driver<[Book]>
    }
    
    private var page: Int = 1
    private var isEnd: Bool = true
    private var searchResults: [Book] = []
    
    func transform(input: Input) -> Output {
        
        let recentResearches = BehaviorRelay<[String]>(value: [])
        let searchResults = PublishRelay<[Book]>()
        let paginationBookSearches = PublishRelay<[Book]>()
        
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
        
        input.deleteRecentSearch
            .map { RecentResultsManager.remove(of: $0) }
            .subscribe()
            .disposed(by: disposeBag)
        
        // update search results
        let bookSearchResponse = input.tapSearchButton
            .withLatestFrom(input.searchKeyword)
            .withUnretained(self)
            .flatMap { owner, keyword in
                return owner.requestSearch(keyword: keyword)
            }
        
        bookSearchResponse
            .withUnretained(self)
            .map { owner, response in
                owner.isEnd = response.meta.isEnd
                
                let books = response.toDomain().books
                owner.searchResults.append(contentsOf: books)
                
                return owner.searchResults
            }
            .bind(to: searchResults)
            .disposed(by: disposeBag)
        
        let pagination = input.willDisplayCell
            .withUnretained(self)
            .filter { (owner, indexPath) in
                return !owner.isEnd && (owner.searchResults.count - 1) == indexPath.item
            }
            .map {(owner, value) in
                owner.page += 1
            }
        
        // TODO: - 로직 개선
        pagination
            .withLatestFrom(input.searchKeyword)
            .withUnretained(self)
            .flatMap { owner, keyword in
                return owner.requestSearch(keyword: keyword)
            }
            .withUnretained(self)
            .map { owner, response in
                owner.isEnd = response.meta.isEnd
                
                let books = response.toDomain().books
                owner.searchResults.append(contentsOf: books)
                
                return owner.searchResults
            }
            .bind(to: paginationBookSearches)
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
                RecentResultsManager.save(keyword)
                return owner.requestSearch(keyword: keyword)
            }
            .withUnretained(self)
            .map { owner, response in
                owner.isEnd = response.meta.isEnd
                
                let books = response.toDomain().books
                owner.searchResults.append(contentsOf: books)
                
                return owner.searchResults
            }
            .bind(to: searchResults)
            .disposed(by: disposeBag)
        
        return Output(recentResearches: recentResearches.asDriver(),
                      bookSearches: searchResults.asDriver(onErrorJustReturn: []),
                      paginationBookSearches: paginationBookSearches.asDriver(onErrorJustReturn: []))
    }
    
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
