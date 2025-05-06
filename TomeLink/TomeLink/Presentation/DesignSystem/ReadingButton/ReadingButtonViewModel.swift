//
//  ReadingButtonViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/10/25.
//

import Foundation

import RxSwift
import RxCocoa

final class ReadingButtonViewModel: BaseViewModel {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let isSelectedState: ControlProperty<Bool>
        let selectButton: ControlEvent<Void>
    }
    
    struct Output {
        let selectedState: Driver<Bool>
    }
    
    private let isbn: String
    private let book: Book
    private let repository: ReadingRepositoryProtocol
    
    init(book: Book, repository: ReadingRepositoryProtocol) {
        self.book = book
        self.isbn = book.isbn
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let selectedState = BehaviorRelay(value: false)
        
        Observable<String>.just(isbn)
            .withUnretained(self)
            .map{ owner, isnb in
                !owner.repository.isBookReading(isbn: isnb)
            }
            .bind(to: selectedState)
            .disposed(by: disposeBag)
        
        return Output(selectedState: selectedState.asDriver())
    }
}
