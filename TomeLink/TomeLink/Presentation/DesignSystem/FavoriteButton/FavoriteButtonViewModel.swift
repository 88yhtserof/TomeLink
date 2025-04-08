//
//  FavoriteButtonViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

import RxSwift
import RxCocoa

final class FavoriteButtonViewModel: BaseViewModel {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let isSelectedState: ControlProperty<Bool>
        let selectButton: ControlEvent<Void>
    }
    
    struct Output {
        let selectedState: Driver<Bool>
        let savingMessage: Driver<(String, String)>
    }
    
    private let isbn: String
    private let book: Book
    private let repository: FavoriteRepositoryProtocol
    
    init(book: Book, repository: FavoriteRepositoryProtocol) {
        self.book = book
        self.isbn = book.isbn
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let selectedState = BehaviorRelay(value: false)
        let savingMessage = PublishRelay<(String, String)>()
        
        input.selectButton
            .withLatestFrom(input.isSelectedState)
            .withUnretained(self)
            .map { owner, isFavorite in
                if isFavorite {
                    
                    owner.repository.like(book: owner.book)
                    return ("읽고 싶은 도서 목록에 추가 되었습니다.", owner.isbn)
                } else {
                    
                    owner.repository.unlike(isbn: owner.isbn)
                    return ("읽고 싶은 도서 목록에서 제거 되었습니다.", owner.isbn)
                }
            }
            .bind(to: savingMessage)
            .disposed(by: disposeBag)
        
        Observable<String>.just(isbn)
            .withUnretained(self)
            .map{ owner, isnb in
                return owner.repository.isBookLiked(for: isnb)
            }
            .bind(to: selectedState)
            .disposed(by: disposeBag)
        
        return Output(selectedState: selectedState.asDriver(),
                      savingMessage: savingMessage.asDriver(onErrorJustReturn: ("", "")))
    }
}
