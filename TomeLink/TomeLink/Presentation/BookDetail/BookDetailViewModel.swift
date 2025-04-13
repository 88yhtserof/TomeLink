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
        let tapReadingButton: ControlEvent<Void>
    }
    
    struct Output {
        let isConnectedToNetwork: Driver<Bool>
        
        let book: Driver<Book>
        let reading: Driver<Book?>
        let popViewController: Driver<Void>
    }
    
    private let networkStatusUseCase: ObserveNetworkStatusUseCase
    
    private let book: Book
    
    init(book: Book, networkStatusUseCase: ObserveNetworkStatusUseCase) {
        self.networkStatusUseCase = networkStatusUseCase
        self.book = book
    }
    
    func transform(input: Input) -> Output {
        
        let isConnectedToNetwork =  BehaviorRelay<Bool>(value: false)
        let book = BehaviorRelay<Book>(value: book)
        let reading = PublishRelay<Book?>()
        let popViewController = PublishRelay<Void>()
        
        // reading
        
        input.tapReadingButton
            .withUnretained(self)
            .map { owner, _ in
                return owner.book
            }
            .bind(to: reading)
            .disposed(by: disposeBag)
        
        // network status
        
        networkStatusUseCase.isConnected
            .bind(to: isConnectedToNetwork)
            .disposed(by: disposeBag)
        
        outputEvent
            .map{ _ in  Void() }
            .bind(to: popViewController)
            .disposed(by: disposeBag)
            
        
        return Output(isConnectedToNetwork: isConnectedToNetwork.asDriver(onErrorJustReturn: false),
                      book: book.asDriver(),
                      reading: reading.asDriver(onErrorJustReturn: nil),
                      popViewController: popViewController.asDriver(onErrorJustReturn: ()))
    }
}
