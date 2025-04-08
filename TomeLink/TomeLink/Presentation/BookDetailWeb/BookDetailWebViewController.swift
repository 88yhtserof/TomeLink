//
//  BookDetailWebViewController.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/8/25.
//

import UIKit
import WebKit

import SnapKit
import RxSwift
import RxCocoa

final class BookDetailWebViewController: UIViewController {
    
    private let webView = WKWebView(frame: .zero)
    
    private let viewModel: BookDetailWebViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: BookDetailWebViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureConstraints()
        configureView()
        bind()
    }
    
    private func bind() {
        
        let input = BookDetailWebViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.url
            .compactMap{ $0 }
            .drive(webView.rx.load)
            .disposed(by: disposeBag)
    }
}

//MARK: - Configuration
private extension BookDetailWebViewController {
    
    func configureView() {
        
        view.backgroundColor = TomeLinkColor.background
        
    }
    
    func configureHierarchy() {
        view.addSubviews(webView)
    }
    
    func configureConstraints() {
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
