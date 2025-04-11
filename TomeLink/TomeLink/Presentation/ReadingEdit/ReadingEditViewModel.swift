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
        
        Observable
            .zip(response, input.currentPage, input.startedAt)
            .bind(with: self) { owner, value in
                print("Add Reading")
                let (response, currentPage, startedAt) = value
                owner.repository.addReading(book: owner.book, currentPage: Int32(currentPage) ?? 0, pageCount: Int32(response?.item?.bookinfo?.itemPage ?? 100), startedAt: startedAt)
                
                doneAddingReading.accept(Void())
            }
            .disposed(by: disposeBag)
        
        return Output(doneAddingReading: doneAddingReading.asDriver(onErrorJustReturn: Void()))
    }
    
}
