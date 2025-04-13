//
//  BookDetailViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/7/25.
//

import Foundation

import RxSwift
import RxCocoa

final class BookDetailViewModel: BaseViewModel, OutputEventEmittable {
    
    var disposeBag = DisposeBag()
    var outputEvent = PublishRelay<OutputEvent>()
    
    struct Input {
        let viewWillAppear: ControlEvent<Void>
        let viewWillDisappear: ControlEvent<Void>
        let tapReadingButton: ControlEvent<Void>
    }
    
    struct Output {
        let isConnectedToNetwork: Driver<Bool>
        
        let book: Driver<Book>
        let reading: Driver<Book?>
    }
    
    private let networkStatusUseCase: ObserveNetworkStatusUseCase
    
    private let book: Book
    
    init(book: Book, networkStatusUseCase: ObserveNetworkStatusUseCase) {
        self.networkStatusUseCase = networkStatusUseCase
        self.book = book
    }
    
    func transform(input: Input) -> Output {
        
        let isConnectedToNetwork = PublishRelay<Bool>()
        let book = BehaviorRelay<Book>(value: book)
        let reading = PublishRelay<Book?>()
        
        // reading
        
        input.tapReadingButton
            .withUnretained(self)
            .map { owner, _ in
                return owner.book
            }
            .bind(to: reading)
            .disposed(by: disposeBag)
        
        // network status
        
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
        
        networkStatusUseCase.isConnected
            .bind(to: isConnectedToNetwork)
            .disposed(by: disposeBag)
            
        
        return Output(isConnectedToNetwork: isConnectedToNetwork.asDriver(onErrorJustReturn: false),
                      book: book.asDriver(),
                      reading: reading.asDriver(onErrorJustReturn: nil))
    }
}
