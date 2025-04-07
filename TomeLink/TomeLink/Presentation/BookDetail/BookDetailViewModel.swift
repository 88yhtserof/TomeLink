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
        
    }
    
    struct Output {
        let book: Driver<Book>
    }
    
    private let book: Book
    
    init(book: Book) {
        self.book = book
    }
    
    func transform(input: Input) -> Output {
        
        let book = BehaviorRelay(value: book)
        
        
        return Output(book: book.asDriver())
    }
}
