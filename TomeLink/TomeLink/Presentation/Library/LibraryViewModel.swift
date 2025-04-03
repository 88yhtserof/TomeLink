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
        
        let thumbnails = ["https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5450099%3Ftimestamp%3D20250319144818", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6458653%3Ftimestamp%3D20250208152926", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F4751039%3Ftimestamp%3D20190302121725", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F540501%3Ftimestamp%3D20241120115010", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6633286%3Ftimestamp%3D20250208153008", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6861926%3Ftimestamp%3D20250401155537", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6062691%3Ftimestamp%3D20240528172936", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F540854%3Ftimestamp%3D20241122114045"]
        
        let titleList = BehaviorRelay(value: titleList)
        let indicatorList = BehaviorRelay(value: indicatorList)
        let contentList = BehaviorRelay<[LibraryViewController.Item]>(value: [.content(.toRead(thumbnails)), .content(.read([])), .content(.reading([]))])
        
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
