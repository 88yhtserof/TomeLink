//
//  Reactive+UISearchBar.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import UIKit

import RxSwift
import RxCocoa

extension Reactive where Base: UISearchBar {
    
    var endEditing: Binder<Void> {
        return Binder(base) { base, _ in
            base.searchTextField.resignFirstResponder()
        }
    }
}
