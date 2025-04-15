//
//  BookDetailWebViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/8/25.
//

import Foundation

import RxSwift
import RxCocoa

final class BookDetailWebViewModel: BaseViewModel {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let url: Driver<URL?>
    }
    
    private let url: String
    
    init(url: String) {
        self.url = url
    }
    
    func transform(input: Input) -> Output {
        
        let url = BehaviorRelay<URL?>(value: nil)
        
        
        Observable.just(self.url)
            .compactMap{ URL(string: $0) }
            .bind(to: url)
            .disposed(by: disposeBag)
        
        return Output(url: url.asDriver())
    }
}
