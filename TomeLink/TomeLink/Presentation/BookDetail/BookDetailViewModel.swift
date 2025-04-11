//
//  BookDetailViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/7/25.
//

import Foundation

import RxSwift
import RxCocoa

final class BookDetailViewModel: BaseViewModel {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let tapReadingButton: ControlEvent<Void>
    }
    
    struct Output {
        let book: Driver<Book>
        let reading: Driver<Book?>
    }
    
    private let book: Book
    
    init(book: Book) {
        self.book = book
    }
    
    func transform(input: Input) -> Output {
        
        let book = BehaviorRelay<Book>(value: book)
        let reading = PublishRelay<Book?>()
        
        input.tapReadingButton
            .withUnretained(self)
            .map { owner, _ in
                return owner.book
            }
            .bind(to: reading)
            .disposed(by: disposeBag)
        
        return Output(book: book.asDriver(),
                      reading: reading.asDriver(onErrorJustReturn: nil))
    }
}
