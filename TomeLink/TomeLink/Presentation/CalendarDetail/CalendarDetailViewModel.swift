//
//  CalendarDetailViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 5/1/25.
//

import Foundation

import RxSwift
import RxCocoa

final class CalendarDetailViewModel: BaseViewModel, OutputEventEmittable {
    
    var disposeBag = DisposeBag()
    var outputEvent = PublishRelay<OutputEvent>()
    
    struct Input {
        let viewWillAppear: ControlEvent<Void>
    }
    
    struct Output {
        let date: Driver<Date>
        let books: Driver<[Book]>
        let bookWithDateList: Driver<[(Date, Book)]>
    }
    
    private let date: Date
    private let books: [Book]
    
    init(date: Date, books: [Book]) {
        self.date = date
        self.books = books
    }
    
    func transform(input: Input) -> Output {
        
        let date = BehaviorRelay<Date>(value: date)
        let books = BehaviorRelay<[Book]>(value: books)
        let bookWithDateList = BehaviorRelay<[(Date, Book)]>(value: [])
        
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                
                let list = owner.books.map{ (owner.date, $0) }
                bookWithDateList.accept(list)
            }
            .disposed(by: disposeBag)
        
        return Output(date: date.asDriver(),
                      books: books.asDriver(),
                      bookWithDateList: bookWithDateList.asDriver())
    }
}
