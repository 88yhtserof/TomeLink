//
//  CalendarViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/19/25.
//

import Foundation

import RxSwift
import RxCocoa

final class CalendarViewModel: BaseViewModel {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let archives: Driver<[Archive]>
    }
    
    private let archives: [Archive]
    
    init(archives: [Archive]) {
        self.archives = archives
    }
    
    func transform(input: Input) -> Output {
        let archives = BehaviorRelay<[Archive]>(value: archives)
        
        return Output(archives: archives.asDriver())
    }
    
}
