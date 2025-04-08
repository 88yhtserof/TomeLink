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
    }
    
    struct Output {
        let listToRead: Driver<[Book]>
    }
    
    private let repository: FavoriteRepositoryProtocol
    
    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let listToRead = BehaviorRelay<[Book]>(value: [])
        
        input.viewWillAppear
            .withUnretained(self)
            .map { owner, _ in owner.repository.fetchFavorites() }
            .bind(to: listToRead)
            .disposed(by: disposeBag)
        
        return Output(listToRead: listToRead.asDriver())
    }
    
}
