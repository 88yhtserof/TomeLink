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
        let viewWillAppear: ControlEvent<Void>
        let viewWillDisappear: ControlEvent<Void>
        
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
    }
    
    private let networkStatusUseCase: ObserveNetworkStatusUseCase
    
    private var searchKeyword: String?
    private var page: Int = 1
    private var isEnd: Bool = true
    private var searchResults: [Book] = []
    
    init(networkStatusUseCase: ObserveNetworkStatusUseCase) {
        self.networkStatusUseCase = networkStatusUseCase
    }
    
    func transform(input: Input) -> Output {
        
        let recentResearches = BehaviorRelay<[String]>(value: [])
        let searchResults = PublishRelay<[Book]>()
        let emptySearchResults = PublishRelay<String>()
        let paginationBookSearches = PublishRelay<[Book]>()
        let isLoading = PublishRelay<Bool>()
        let isConnectedToNetwork = PublishRelay<Bool>()
        
        // Network Monitoring
        
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                owner.networkStatusUseCase.start()
            }
            .disposed(by: disposeBag)
        
        input.viewWillDisappear
            .bind(with: self) { owner, _ in
                owner.networkStatusUseCase.stop()
            }
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
                return owner.requestSearch(keyword: keyword, isConnectedToNetwork: isConnectedToNetwork, isLoading: isLoading)
            }
            .share()
        
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
                isLoading.accept(true)
                RecentResultsManager.save(keyword)
                return owner.requestSearch(keyword: keyword, isConnectedToNetwork: isConnectedToNetwork, isLoading: isLoading)
            }
            .withUnretained(self)
            .map { owner, response in
                isLoading.accept(false)
                owner.isEnd = response.meta.isEnd
                
                let books = response.toDomain().books
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
        
        // network status
        
        networkStatusUseCase.isConnected
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: isConnectedToNetwork)
            .disposed(by: disposeBag)
        
        return Output(isConnectedToNetwork: isConnectedToNetwork.asDriver(onErrorJustReturn: false),
                      recentResearches: recentResearches.asDriver(),
                      bookSearches: searchResults.asDriver(onErrorJustReturn: []),
                      emptySearchResults: emptySearchResults.asDriver(onErrorJustReturn: ""),
                      paginationBookSearches: paginationBookSearches.asDriver(onErrorJustReturn: []),
                      isLoading: isLoading.asDriver(onErrorJustReturn: false))
    }
}

//MARK: - Feature
private extension SearchViewModel {
    
    /// Requests search to Kakao Book API
    func requestSearch(keyword: String,
                       isConnectedToNetwork: PublishRelay<Bool>,
                       isLoading: PublishRelay<Bool>) -> Observable<BookSearchResponseDTO> {
        return Observable.just(keyword)
            .distinctUntilChanged()
            .withUnretained(self)
            .flatMap { owner, text in
                return NetworkRequestingManager.shared
                    .request(api: KakaoNetworkAPI.searchBook(query: text, sort: nil, page: owner.page, size: 20, target: nil))
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
            }
            .compactMap{ $0 }
    }
}
