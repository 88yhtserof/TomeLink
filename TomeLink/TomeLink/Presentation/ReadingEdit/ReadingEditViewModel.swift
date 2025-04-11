//
//  ReadingEditViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/11/25.
//

import Foundation

import RxSwift
import RxCocoa

final class ReadingEditViewModel: BaseViewModel {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let tapDoneButton: ControlEvent<Void>
        let currentPage: ControlProperty<String>
        let startedAt: ControlProperty<Date>
    }
    
    struct Output {
        let doneAddingReading: Driver<Void>
    }
    
    private let book: Book
    
    private let repository: ReadingRepositoryProtocol
    
    init(book: Book, repository: ReadingRepositoryProtocol) {
        self.book = book
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let doneAddingReading = PublishRelay<Void>()
        
        let response = input.tapDoneButton
            .withUnretained(self)
            .flatMap { owner, _ in
                return NetworkRequestingManager.shared
                    .requestXML(api: AladinNetworkAPI.itemLookUp(isbn: owner.book.isbn), type: AladinItemLookUpResponseDTO?.self)
                    .catch { error in
                        print("Error: \(error)")
                        return Single<AladinItemLookUpResponseDTO?>.just(nil)
                    }
            }
            .share()
        
        let currentPage = BehaviorRelay<String>(value: "0")
        let startedAt = BehaviorRelay<Date>(value: Date())
        
        input.currentPage
            .map{
                print($0)
                return $0
            }
            .bind(to: currentPage)
            .disposed(by: disposeBag)
        
        input.startedAt
            .bind(to: startedAt)
            .disposed(by: disposeBag)
        
        let input = Observable.combineLatest(currentPage, startedAt)
        
        response
            .withLatestFrom(input){ ($0, $1) }
            .bind(with: self) { owner, value in
                print("Add Reading")
                let (response, input) = value
                let (currentPage, startedAt) = input
                
                if owner.repository.isBookReading(isbn: owner.book.isbn) {
                    owner.repository.updateCurrentPage(isbn: owner.book.isbn, currentPage: Int32(currentPage) ?? 0)
                } else {
                    owner.repository.addReading(book: owner.book, currentPage: Int32(currentPage) ?? 0, pageCount: Int32(response?.item?.bookinfo?.itemPage ?? 100), startedAt: startedAt)
                }
                
                doneAddingReading.accept(Void())
            }
            .disposed(by: disposeBag)
        
        return Output(doneAddingReading: doneAddingReading.asDriver(onErrorJustReturn: Void()))
    }
    
}
