//
//  SearchViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

import RxSwift
import RxCocoa

final class SearchViewModel: BaseViewModel, OutputEventEmittable {
    
    var disposeBag = DisposeBag()
    var outputEvent = PublishRelay<OutputEvent>()
    
    struct Input {
        let viewWillAppear: ControlEvent<Void>
        let willDisplayCell: Observable<IndexPath>
        let selectRecentSearchesItem: PublishRelay<String>
        let selectSearchResultItem: PublishRelay<Book>
        
        let searchKeyword: ControlProperty<String>
        let tapSearchButton: ControlEvent<Void>
        let tapSearchCancelButton: ControlEvent<Void>
    }
    
    struct Output {
        let isConnectedToNetwork: Driver<Bool>
        
        let recentResearches: Driver<[String]>
        let bookSearches: Driver<[Book]>
        let emptySearchResults: Driver<String>
        let paginationBookSearches: Driver<[Book]>
        let isLoading: Driver<Bool>
        let switchingSeletedTabBarIndex: Driver<Int>
    }
    
    private let networkStatusUseCase: ObserveNetworkStatusUseCase
    private let searchUseCase: SearchUseCase
    
    private var searchKeyword: String?
    private var page: Int = 1
    private var isEnd: Bool = true
    private var searchResults: [Book] = []
    
    init(networkStatusUseCase: ObserveNetworkStatusUseCase, searchUseCase: SearchUseCase) {
        self.networkStatusUseCase = networkStatusUseCase
        self.searchUseCase = searchUseCase
    }
    
    func transform(input: Input) -> Output {
        
        let recentResearches = BehaviorRelay<[String]>(value: [])
        let searchResults = PublishRelay<[Book]>()
        let emptySearchResults = PublishRelay<String>()
        let paginationBookSearches = PublishRelay<[Book]>()
        let isLoading = PublishRelay<Bool>()
        let isConnectedToNetwork = BehaviorRelay<Bool>(value: true)
        let switchingSeletedTabBarIndex = PublishRelay<Int>()
        
        // network status
        
        networkStatusUseCase.isConnected
            .bind(to: isConnectedToNetwork)
            .disposed(by: disposeBag)
        
        input.viewWillAppear
            .withLatestFrom(networkStatusUseCase.isConnected)
            .bind(to: isConnectedToNetwork)
            .disposed(by: disposeBag)
        
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
            .share()
        
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
            .share()
        
        let bookSearchResponse = Observable.of(searchByButton, pagination)
            .merge()
            .withUnretained(self)
            .flatMap { owner, keyword in
                owner.searchKeyword = keyword
                isLoading.accept(true)
                return owner.searchUseCase.search(keyword: keyword, page: owner.page, isConnectedToNetwork: isConnectedToNetwork, isLoading: isLoading)
            }
            .share()
        
        bookSearchResponse
            .withUnretained(self)
            .map { owner, response in
                isLoading.accept(false)
                owner.isEnd = response.meta.isEnd
                
                let books = response.books
                owner.searchResults.append(contentsOf: books)
                return owner.searchResults
            }
            .bind(with: self) { owner, list in
                if owner.page == 1 {
                    if list.isEmpty {
                        emptySearchResults.accept("검색결과가 없습니다.")
                    } else {
                        searchResults.accept(list)
                    }
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
                owner.page = 1
                isLoading.accept(true)
                RecentResultsManager.save(keyword)
                return owner.searchUseCase.search(keyword: keyword, page: owner.page, isConnectedToNetwork: isConnectedToNetwork, isLoading: isLoading)
            }
            .withUnretained(self)
            .map { owner, response in
                isLoading.accept(false)
                owner.isEnd = response.meta.isEnd
                
                let books = response.books
                owner.searchResults.append(contentsOf: books)
                
                return owner.searchResults
            }
            .bind(with: self) { owner, list in
                if list.isEmpty {
                    emptySearchResults.accept("검색결과가 없습니다.")
                } else {
                    searchResults.accept(list)
                }
            }
            .disposed(by: disposeBag)
        
        // output event
        outputEvent
            .map{ _ in TabBarController.Item.library.index }
            .bind(to: switchingSeletedTabBarIndex)
            .disposed(by: disposeBag)
        
        return Output(isConnectedToNetwork: isConnectedToNetwork.asDriver(onErrorJustReturn: false),
                      recentResearches: recentResearches.asDriver(),
                      bookSearches: searchResults.asDriver(onErrorJustReturn: []),
                      emptySearchResults: emptySearchResults.asDriver(onErrorJustReturn: ""),
                      paginationBookSearches: paginationBookSearches.asDriver(onErrorJustReturn: []),
                      isLoading: isLoading.asDriver(onErrorJustReturn: false),
                      switchingSeletedTabBarIndex: switchingSeletedTabBarIndex.asDriver(onErrorJustReturn: 0))
    }
}
