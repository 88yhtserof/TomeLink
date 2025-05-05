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
        let date: Driver<Date>
        let note: Driver<String?>
    }
    
    private let isbn: String
    private let book: Book
    private let archiveID: UUID?
    private let repository: ArchiveRepository
    
    
    init(book: Book, archiveID: UUID? = nil, repository: ArchiveRepository) {
        self.book = book
        self.isbn = book.isbn
        self.archiveID = archiveID
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        // output
        let dismiss = PublishRelay<Void>()
        let date = BehaviorRelay<Date>(value: Date())
        let note = BehaviorRelay<String?>(value: nil)
        
        
        // init views with the recieved data
        let archiveID = Observable<UUID?>.just(archiveID)
        
        archiveID
            .compactMap{ $0 }
            .bind(with: self) { owner, id in
                guard let archive = owner.repository.fetchArchive(for: id) else { return }
                date.accept(archive.archivedAt)
                note.accept(archive.note)
            }
            .disposed(by: disposeBag)
        
        
        // observable
        let archivedAt = Observable
            .merge(input.archivedAt.asObservable(),
                   date.asObservable())
        
        let contentsToArchive = Observable
            .combineLatest(input.note, archivedAt)
        
        input.tapDoneButton
            .withLatestFrom(contentsToArchive)
            .bind(with: self) { owner, contents in
                let (note, archivedAt) = contents
                
                if let id = owner.archiveID {
                    let archive = Archive(id: id, archivedAt: archivedAt, isbn: owner.isbn, note: note, book: owner.book)
                    owner.repository.updateArchive(at: id, with: archive)
                } else {
                    owner.repository.addArchive(book: owner.book, note: note, archivedAt: archivedAt)
                }

                dismiss.accept(())
            }
            .disposed(by: disposeBag)
        
        return Output(dismiss: dismiss.asDriver(onErrorDriveWith: .empty()),
                      date: date.asDriver(),
                      note: note.asDriver())
    }
}
