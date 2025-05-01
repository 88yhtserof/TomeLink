//
//  ArchiveEditViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/29/25.
//

import Foundation

import RxSwift
import RxCocoa

final class ArchiveEditViewModel: BaseViewModel {
        
    let disposeBag = DisposeBag()
    
    struct Input {
        let tapDoneButton: ControlEvent<Void>
        let archivedAt: ControlProperty<Date>
        let note: ControlProperty<String?>
    }
    
    struct Output {
        let dismiss: Driver<Void>
    }
    
    private let isbn: String
    private let book: Book
    private let repository: ArchiveRepository
    
    
    init(book: Book, repository: ArchiveRepository) {
        self.book = book
        self.isbn = book.isbn
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let dismiss = PublishRelay<Void>()
        
        let contentsToArchive = Observable
            .combineLatest(input.note, input.archivedAt)
        
        input.tapDoneButton
            .withLatestFrom(contentsToArchive)
            .bind(with: self) { owner, contents in
                let (note, archivedAt) = contents
                owner.repository.addArchive(book: owner.book, note: note, archivedAt: archivedAt)
                dismiss.accept(())
            }
            .disposed(by: disposeBag)
        
        return Output(dismiss: dismiss.asDriver(onErrorDriveWith: .empty()))
    }
}
