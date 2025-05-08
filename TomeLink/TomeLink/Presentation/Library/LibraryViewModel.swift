//
//  LibraryViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/9/25.
//

import Foundation

import RxSwift
import RxCocoa

final class LibraryViewModel: BaseViewModel, OutputEventEmittable {
    
    var disposeBag = DisposeBag()
    var outputEvent = PublishRelay<OutputEvent>()
    
    struct Input {
        let latestCategory: Observable<LibraryViewController.Section>
        let viewWillAppear: ControlEvent<Void>
        let tapToReadCategory: PublishRelay<Void>
        let tapReadingCategory: PublishRelay<Void>
        let tapArchiveCategory: PublishRelay<Void>
        let didFavoriteButtonMessageSent: ControlEvent<String>
    }
    
    struct Output {
        let listToRead: Driver<[Book]>
        let listReading: Driver<[Reading]>
        let listArchive: Driver<[Archive]>
        let emptyList: Driver<String>
    }
    
    private let favoriteRepository: FavoriteRepositoryProtocol
    private let readingRepository: ReadingRepositoryProtocol
    private let archiveRepository: ArchiveRepositoryProtocol
    
    init(favoriteRepository: FavoriteRepositoryProtocol,
         readingRepository: ReadingRepositoryProtocol,
         archiveRepository: ArchiveRepositoryProtocol)
    {
        self.favoriteRepository = favoriteRepository
        self.readingRepository = readingRepository
        self.archiveRepository = archiveRepository
    }
    
    func transform(input: Input) -> Output {
        
        // output
        let listToRead = BehaviorRelay<[Book]>(value: [])
        let listReading = PublishRelay<[Reading]>()
        let listArchive = PublishRelay<[Archive]>()
        let emptyList = BehaviorRelay<String>(value: "")
        
        // viewWillAppear
        let toReadWillAppear = BehaviorRelay<Void>(value: ())
        let readingWillAppear = BehaviorRelay<Void>(value: ())
        let archiveWillAppear = BehaviorRelay<Void>(value: ())
        
        input.viewWillAppear
            .withLatestFrom(input.latestCategory)
            .bind { category in
                switch category {
                case .toRead:
                    toReadWillAppear.accept(())
                case .reading:
                    readingWillAppear.accept(())
                case .archive:
                    archiveWillAppear.accept(())
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        
        // section
        Observable.of(toReadWillAppear.asObservable(),
                      input.tapToReadCategory.asObservable(),
                      input.didFavoriteButtonMessageSent.map{ _ in Void() }.asObservable())
            .merge()
            .withUnretained(self)
            .map { owner, _ in owner.favoriteRepository.fetchFavorites() }
            .bind(with: self) { owner, favorites in
                
                if favorites.isEmpty {
                    emptyList.accept("아직 저장된 도서가 없습니다.")
                } else {
                    listToRead.accept(favorites)
                }
            }
            .disposed(by: disposeBag)
        
        Observable.of(readingWillAppear.asObservable(),
                      input.tapReadingCategory.asObservable())
            .merge()
            .withUnretained(self)
            .map { owner, _ in owner.readingRepository.fetchAllReadings() }
            .bind(with: self) { owner, readings in
                
                if readings.isEmpty {
                    emptyList.accept("아직 저장된 도서가 없습니다.")
                } else {
                    listReading.accept(readings)
                }
            }
            .disposed(by: disposeBag)
        
        Observable.of(archiveWillAppear.asObservable(),
                      input.tapArchiveCategory.asObservable())
        .merge()
            .bind(with: self) { owner, _ in
                let list = owner.archiveRepository.fetchAllArchives()
                listArchive.accept(list)
            }
            .disposed(by: disposeBag)
        
        return Output(listToRead: listToRead.asDriver(),
                      listReading: listReading.asDriver(onErrorJustReturn: []),
                      listArchive: listArchive.asDriver(onErrorJustReturn: []),
                      emptyList: emptyList.asDriver())
    }
    
}
