//
//  SearchViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

import RxSwift
import RxCocoa

final class SearchViewModel: BaseViewModel {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let recentResearches: Driver<[String]>
    }
    
    func transform(input: Input) -> Output {
        
        let recentResearches = BehaviorRelay<[String]>(value: [])
        
        RecentResultsManager.elements
            .bind(to: recentResearches)
            .disposed(by: disposeBag)
        
        return Output(recentResearches: recentResearches.asDriver())
    }
}
