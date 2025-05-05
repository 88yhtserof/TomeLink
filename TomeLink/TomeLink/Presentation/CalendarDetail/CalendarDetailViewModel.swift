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
        let deleteBook: Observable<IndexPath>
        let selectBook: ControlEvent<IndexPath>
    }
    
    struct Output {
        let books: Driver<[Book]>
        let bookWithDateList: Driver<[(Date, Book)]>
        let presentArchiveEdit: Driver<(Book, Archive.ID)>
    }
    
    private let date: Date
    private let archiveRepository: ArchiveRepositoryProtocol
    
    init(date: Date, archiveRepository: ArchiveRepositoryProtocol) {
        self.date = date
        self.archiveRepository = archiveRepository
    }
    
    func transform(input: Input) -> Output {
        
        // ouput
        let archives = BehaviorRelay<[Archive]>(value: [])
        let books = BehaviorRelay<[Book]>(value: [])
        let bookWithDateList = BehaviorRelay<[(Date, Book)]>(value: [])
        let presentArchiveEdit = PublishRelay<(Book, Archive.ID)>()
        
        // observer
        let updateArchives = PublishRelay<Void>()
        
        
        // archive repository
        Observable
            .merge(input.viewWillAppear.asObservable(),
                   updateArchives.asObservable())
            .withUnretained(self)
            .map { owner, _ in
                let list = owner.archiveRepository.fetchAllArchives()
                return list
                    .filter {
                        TomeLinkCalendar.isDate($0.archivedAt, inSameDayAs: owner.date, in: .calendar)
                    }
            }
            .bind(to: archives)
            .disposed(by: disposeBag)
        
        input.deleteBook
            .withLatestFrom(archives){ ($0, $1) }
            .map { (indexPath, list) in
                return list[indexPath.row]
            }
            .withUnretained(self)
            .map { owner, archive in
                owner.archiveRepository.deleteArchive(at: archive.id)
                return Void()
            }
            .bind(to: updateArchives)
            .disposed(by: disposeBag)
        
        
        // books
        archives
            .map { list in
                return list.map{ $0.book }
            }
            .bind(to: books)
            .disposed(by: disposeBag)
        
        archives
            .map { list in
                return list.map{ ($0.archivedAt, $0.book) }
            }
            .bind(to: bookWithDateList)
            .disposed(by: disposeBag)
        
        // present archive edit
        input.selectBook
            .withLatestFrom(archives){ ($0, $1) }
            .map { (indexPath, list) in
                let archive = list[indexPath.row]
                return (archive.book, archive.id)
            }
            .bind(to: presentArchiveEdit)
            .disposed(by: disposeBag)
        
        return Output(books: books.asDriver(),
                      bookWithDateList: bookWithDateList.asDriver(),
                      presentArchiveEdit: presentArchiveEdit.asDriver(onErrorDriveWith: .empty()))
    }
}
