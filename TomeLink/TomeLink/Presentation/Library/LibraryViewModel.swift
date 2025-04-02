//
//  LibraryViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/2/25.
//

import Foundation

import RxSwift
import RxCocoa

final class LibraryViewModel: BaseViewModel {
    
    struct Input {
    }
    
    struct Output {
        let titleList: Driver<[LibraryViewController.Item]>
        let indicatorList: Driver<[LibraryViewController.Item]>
        let contentList: Driver<[LibraryViewController.Item]>
        let itemTuple: Driver<([LibraryViewController.Item], [LibraryViewController.Item], [LibraryViewController.Item])>
    }
    
    var disposeBag = DisposeBag()
    
    private let searchKeyword: String
    private let titleList: [LibraryViewController.Item]
    private let indicatorList: [LibraryViewController.Item]
    
    init(searchKeyword: String) {
        print("LibraryViewModel init")
        
        self.searchKeyword = searchKeyword
        self.titleList = [.title("예정"), .title("진행 중"), .title("완료")]
        self.indicatorList = [.indicator(1), .indicator(2), .indicator(3)]
    }
    
    deinit {
        print("LibraryViewModel deinit")
    }
    
    func transform(input: Input) -> Output {
        
        let titleList = BehaviorRelay(value: titleList)
        let indicatorList = BehaviorRelay(value: indicatorList)
//        let contentList = PublishRelay<[LibraryViewController.Item]>()
        let contentList = BehaviorRelay<[LibraryViewController.Item]>(value: [.content(.toRead(["1", "2", "3"])), .content(.read([])), .content(.reading([]))])
        let searchResultList = BehaviorRelay<LibraryViewController.Item?>(value: nil)
        
        let itemTuple = BehaviorRelay<([LibraryViewController.Item], [LibraryViewController.Item], [LibraryViewController.Item])>(value: ([], [], []))
        
        Observable
            .zip(titleList, indicatorList, contentList)
            .bind(to: itemTuple)
            .disposed(by: disposeBag)
        
        
        return Output(titleList: titleList.asDriver(),
                      indicatorList: indicatorList.asDriver(),
                      contentList: contentList.asDriver(onErrorJustReturn: []),
                      itemTuple: itemTuple.asDriver())
    }
    
}
