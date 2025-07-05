//
//  NotiListViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/3/25.
//

import Foundation

import RxSwift
import RxCocoa

final class NotiListViewModel: BaseViewModel {
    var disposeBag = DisposeBag()
    
    typealias Item = NotiListViewController.Item
    
    struct Input {
        let viewWillAppear: ControlEvent<Void>
        let didAllNotiToggle: ControlProperty<Bool>
        let didRecommendNotiToggle: ControlProperty<Bool>
    }
    
    struct Output {
        let isConnectedToNetwork: Driver<Bool>
        let isLoading: Driver<Bool>
        
        let isAllNotiOn: Driver<Bool>
        let isRecommendNotiOn: Driver<Bool>
        
        let book: Driver<Book?>
        let notiList: Driver<[Item]>
        let emptySearchResult: Driver<String>
    }
    
    private let networkStatusUseCase: ObserveNetworkStatusUseCase
    private let searchUseCase: SearchUseCase
    private let notificationUseCase: NotificationUseCase
    
    
    private let isbn: String?
    private let notiList: [Item] = [Item(item: "오만과 편견")]
    
    // initializer
    init(isbn: String?, networkStatusUseCase: ObserveNetworkStatusUseCase, searchUseCase: SearchUseCase, notificationUseCase: NotificationUseCase) {
        self.isbn = isbn
        self.networkStatusUseCase = networkStatusUseCase
        self.searchUseCase = searchUseCase
        self.notificationUseCase = notificationUseCase
    }
    
    convenience init(networkStatusUseCase: ObserveNetworkStatusUseCase, searchUseCase: SearchUseCase, notificationUseCase: NotificationUseCase) {
        self.init(isbn: nil, networkStatusUseCase: networkStatusUseCase, searchUseCase: searchUseCase, notificationUseCase: notificationUseCase)
    }
    
    func transform(input: Input) -> Output {
        
        let isLoading = PublishRelay<Bool>()
        let isConnectedToNetwork = BehaviorRelay<Bool>(value: true)
        
        let isAllNotiOn = BehaviorRelay<Bool>(value: true)
        let isRecommendNotiOn = BehaviorRelay<Bool>(value: true)
        
        let isbn = BehaviorRelay(value: isbn)
        let notiList = BehaviorRelay<[Item]>(value: [])
        
        let book = BehaviorRelay<Book?>(value: nil)
        let emptySearchResult = PublishRelay<String>()
    
        
        // network status
        networkStatusUseCase.isConnected
            .bind(to: isConnectedToNetwork)
            .disposed(by: disposeBag)
        
        // load noti list
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                notiList.accept(owner.notiList)
                isAllNotiOn.accept(owner.notificationUseCase.isSubscribed(to: .all))
                isRecommendNotiOn.accept(owner.notificationUseCase.isSubscribed(to: .recommend))
            }
            .disposed(by: disposeBag)
        
        // push noti isbn
        isbn
            .compactMap{ $0 }
            .withUnretained(self)
            .flatMap { owner, keyword in
                isLoading.accept(true)
                return owner.searchUseCase.search(keyword: keyword, page: 1, isConnectedToNetwork: isConnectedToNetwork, isLoading: isLoading)
            }
            .map { response in
                isLoading.accept(false)
                return response.books.first
            }
            .bind{ result in
                if let result {
                    book.accept(result)
                } else {
                    emptySearchResult.accept("해당 도서를 찾을 수 없습니다.")
                }
            }
            .disposed(by: disposeBag)
        
        // notifications setting view
        input.didAllNotiToggle
            .skip(1)
            .bind(with: self) { owner, isSubscribed in
                
                if isSubscribed {
                    owner.notificationUseCase.subscribe(to: .all)
                } else {
                    owner.notificationUseCase.unsubscribe(from: .all)
                }
            }
            .disposed(by: disposeBag)
        
        input.didRecommendNotiToggle
            .skip(1)
            .bind(with: self) { owner, isSubscribed in
                
                if isSubscribed {
                    owner.notificationUseCase.subscribe(to: .recommend)
                } else {
                    owner.notificationUseCase.unsubscribe(from: .recommend)
                }
            }
            .disposed(by: disposeBag)
        
        return NotiListViewModel.Output(
            isConnectedToNetwork: isConnectedToNetwork.asDriver(),
            isLoading: isLoading.asDriver(onErrorJustReturn: false),
            isAllNotiOn: isAllNotiOn.asDriver(),
            isRecommendNotiOn: isRecommendNotiOn.asDriver(),
            book: book.asDriver(),
            notiList: notiList.asDriver(),
            emptySearchResult: emptySearchResult.asDriver(onErrorJustReturn: "")
        )
    }
}
