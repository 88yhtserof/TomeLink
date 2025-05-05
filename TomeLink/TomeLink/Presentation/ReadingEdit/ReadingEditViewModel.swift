//
//  ReadingEditViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/11/25.
//

import Foundation

import RxSwift
import RxCocoa

final class ReadingEditViewModel: BaseViewModel, OutputEventEmittable {
    
    var disposeBag = DisposeBag()
    var outputEvent = PublishRelay<OutputEvent>()
    
    struct Input {
        let tapDoneButton: ControlEvent<Void>
        let currentPage: ControlProperty<String>
        let startedAt: ControlProperty<Date>
    }
    
    struct Output {
        let currentPage: Driver<Int>
        let startedAt: Driver<Date>
        let doneAddingReading: Driver<Void>
    }
    
    private let book: Book
    private var pageCurrent: Int?
    
    private let repository: ReadingRepositoryProtocol
    
    init(book: Book, repository: ReadingRepositoryProtocol) {
        self.book = book
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        // output
        let currentPage = BehaviorRelay<Int>(value: 1)
        let startedAt = BehaviorRelay<Date>(value: Date())
        let doneAddingReading = PublishRelay<Void>()
        
        // edit
        let existingReading = Observable
            .just(repository.fetchReading(isbn: book.isbn))
            .share()
        
        existingReading
            .compactMap{ $0 }
            .bind(with: self) { owner, reading in
                
                owner.pageCurrent = reading.pageCount
                currentPage.accept(reading.currentPage)
                startedAt.accept(reading.startedAt)
            }
            .disposed(by: disposeBag)
        
        
        let requestNetworkTrigger = PublishRelay<Void>()
        let existingReadingTrigger = PublishRelay<Int>()
        
        input.tapDoneButton
            .withLatestFrom(existingReading)
            .bind(with: self) { owner, isExistingReading in
                
                if isExistingReading == nil {
                    requestNetworkTrigger.accept(Void())
                } else {
                    existingReadingTrigger.accept(owner.pageCurrent ?? 1)
                }
            }
            .disposed(by: disposeBag)
        
        
        // create
        let response = requestNetworkTrigger
            .withUnretained(self)
            .flatMap { owner, _ in
                return NetworkRequestingManager.shared
                    .requestXML(api: AladinNetworkAPI.itemLookUp(isbn: owner.book.isbn), type: AladinItemLookUpResponseDTO?.self)
                    .catch { error in
                        print("Error: \(error)")
                        return Single<AladinItemLookUpResponseDTO?>.just(nil)
                    }
            }
            .compactMap{ $0?.toDomain() }
            .map{ $0.pageCount }
        
        
        // add or update
        let inputCurrentPage = Observable
            .merge(input.currentPage.compactMap{ Int($0) },
                   currentPage.asObservable())
        let inputStartedAt = Observable
            .merge(input.startedAt.asObservable(),
                   startedAt.asObservable())
        
        let input = Observable.combineLatest(inputCurrentPage, inputStartedAt)
        
        existingReadingTrigger
            .amb(response)
            .withLatestFrom(input){ ($0, $1) }
            .bind(with: self) { owner, value in
                print("Add Reading")
                let (pageCount, input) = value
                let (currentPage, startedAt) = input
                
                if owner.repository.isBookReading(isbn: owner.book.isbn) {
                    owner.repository.updateCurrentPage(isbn: owner.book.isbn, currentPage: Int32(currentPage), startedAt: startedAt)
                } else {
                    owner.repository.addReading(book: owner.book, currentPage: Int32(currentPage), pageCount: Int32(pageCount), startedAt: startedAt)
                }
                
                doneAddingReading.accept(Void())
            }
            .disposed(by: disposeBag)
        
        return Output(currentPage: currentPage.asDriver(),
                      startedAt: startedAt.asDriver(onErrorDriveWith: .empty()),
                      doneAddingReading: doneAddingReading.asDriver(onErrorJustReturn: Void()))
    }
    
}
