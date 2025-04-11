//
//  LibraryViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/9/25.
//

import Foundation

import RxSwift
import RxCocoa

final class LibraryViewModel: BaseViewModel {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let viewWillAppear: ControlEvent<Void>
        let favoriteButtonDidSave: PublishRelay<Void>
        let readingButtonDidSave: PublishRelay<Void>
    }
    
    struct Output {
        let listToRead: Driver<[Book]>
        let listReading: Driver<[Book]>
        let emptyList: Driver<String>
    }
    
    private let favoriteRepository: FavoriteRepositoryProtocol
    private let readingRepository: ReadingRepositoryProtocol
    
    init(favoriteRepository: FavoriteRepositoryProtocol,
         readingRepository: ReadingRepositoryProtocol)
    {
        self.favoriteRepository = favoriteRepository
        self.readingRepository = readingRepository
    }
    
    func transform(input: Input) -> Output {
        
        let listToRead = BehaviorRelay<[Book]>(value: [])
        let listReading = BehaviorRelay<[Book]>(value: [])
        let emptyList = BehaviorRelay<String>(value: "")
        
        Observable.of(input.viewWillAppear.asObservable(),
                      input.favoriteButtonDidSave.asObservable())
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
        
        Observable.of(input.viewWillAppear.asObservable(),
                      input.readingButtonDidSave.asObservable())
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
        
        return Output(listToRead: listToRead.asDriver(),
                      listReading: listReading.asDriver(),
                      emptyList: emptyList.asDriver())
    }
    
}
