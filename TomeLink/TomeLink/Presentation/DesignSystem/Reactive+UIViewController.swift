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
    
    var present: Binder<UIViewController> {
        return Binder(base) { base, viewController in
            base.present(viewController, animated: true)
        }
    }
    
    var pushViewController: Binder<UIViewController> {
        return Binder(base) { base, viewController in
            base.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
