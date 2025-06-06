//
//  Reactive+UIViewController.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/8/25.
//

import UIKit

import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    
    // LifeCycle
    var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { _ in () }
        return ControlEvent(events: source)
    }
    
    var viewWillDisappear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { _ in () }
        return ControlEvent(events: source)
    }
    
    // Shows a view controller
    var present: Binder<UIViewController> {
        return Binder(base) { base, viewController in
            base.present(viewController, animated: true)
        }
    }
    
    var dismiss: Binder<Void> {
        return Binder(base) { base, _ in
            base.dismiss(animated: true)
        }
    }
    
    var pushViewController: Binder<UIViewController> {
        return Binder(base) { base, viewController in
            base.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    var popViewController: Binder<Void> {
        return Binder(base) { base, _ in
            base.navigationController?.popViewController(animated: true)
        }
    }
}
