//
//  FavoriteButtonViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

import RxSwift
import RxCocoa

final class FavoriteButtonViewModel: BaseViewModel {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let isSelectedState: ControlProperty<Bool>
        let selectButton: ControlEvent<Void>
    }
    
    struct Output {
        let selectedState: Driver<Bool>
        let savingMessage: Driver<(String, String)>
    }
    
    private let id: String
    
    init(id: String) {
        print("FavoriteButtonViewModel init")
        self.id = id
    }
    
    deinit {
        print("FavoriteButtonViewModel deinit")
    }
    
    func transform(input: Input) -> Output {
        
        let selectedState = BehaviorRelay(value: false)
        let savingMessage = PublishRelay<(String, String)>()
        
        input.selectButton
            .withLatestFrom(input.isSelectedState)
            .withUnretained(self)
            .map { owner, isFavorite in
                if isFavorite {
                    // TODO: - DataBase 작업
                    return (String(format: "%@이 즐겨찾기에 추가되었습니다.", owner.id), owner.id)
                } else {
                    // TODO: - DataBase 작업
                    return (String(format: "%@이 즐겨찾기에서 제거되었습니다.", owner.id), owner.id)
                }
            }
            .bind(to: savingMessage)
            .disposed(by: disposeBag)
        
        Observable<String>.just(id)
            .map{ object in
                // TODO: - DataBase 작업
                true
            }
            .bind(to: selectedState)
            .disposed(by: disposeBag)
        
        return Output(selectedState: selectedState.asDriver(),
                      savingMessage: savingMessage.asDriver(onErrorJustReturn: ("", "")))
    }
}
