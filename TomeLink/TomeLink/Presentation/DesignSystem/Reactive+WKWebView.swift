//
//  Reactive+WKWebView.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/8/25.
//

import UIKit
import WebKit

import RxSwift
import RxCocoa

extension Reactive where Base: WKWebView {
    var load: Binder<URL> {
        return Binder(base) { base, value in
            let request = URLRequest(url: value)
            base.load(request)
        }
    }
}
