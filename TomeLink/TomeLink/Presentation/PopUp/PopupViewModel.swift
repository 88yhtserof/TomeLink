//
//  PopupViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/13/25.
//

import Foundation

import RxSwift
import RxCocoa

final class PopupViewModel: BaseViewModel {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let tapButton: ControlEvent<Void>
    }
    
    struct Output {
        let dismiss: Driver<Void>
    }
    
    private let eventReceiver: (any OutputEventEmittable)?
    
    init(eventReceiver: (any OutputEventEmittable)? = nil) {
        self.eventReceiver = eventReceiver
    }
    
    func transform(input: Input) -> Output {
        
        let dismiss = PublishRelay<Void>()
        
        input.tapButton
            .bind(with: self) { owner, _ in
                owner.eventReceiver?.outputEvent.accept(.reloadTrigger)
                dismiss.accept(())
            }
            .disposed(by: disposeBag)
        
        return Output(dismiss: dismiss.asDriver(onErrorJustReturn: ()))
    }
}
