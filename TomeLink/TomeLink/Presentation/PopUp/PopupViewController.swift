//
//  PopupViewController.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/12/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class PopupViewController: UIViewController {
    
    private let deemBackgroundView = UIView()
    private let alertBackgroundView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private lazy var alertStackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
    private let button = UIButton()
    
    var configuration: Configuration? {
        didSet {
            if let configuration {
                button.setTitle(configuration.buttonTitle, for: .normal)
                messageLabel.text = configuration.message
            }
        }
    }
    
    var buttonHandler: (() -> Void)?
    
    private let viewModel: PopupViewModel
    private let disposeBag = DisposeBag()
    
    // LifeCycle
    init(viewModel: PopupViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
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
    
    // Binding
    func bind() {
        
        let input = PopupViewModel.Input(tapButton: button.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.dismiss
            .drive(rx.dismiss)
            .disposed(by: disposeBag)
    }
}

//MARK: - Configuration
private extension PopupViewController {
    
    func configureView() {
        
        deemBackgroundView.backgroundColor = .black
        deemBackgroundView.alpha = 0.2
        
        alertBackgroundView.backgroundColor = TomeLinkColor.background
        
        titleLabel.text = "안내"
        titleLabel.font = TomeLinkFont.title
        titleLabel.textColor = TomeLinkColor.title
        titleLabel.textAlignment = .center
        
        messageLabel.font = TomeLinkFont.contents
        messageLabel.textColor = TomeLinkColor.title
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        alertStackView.axis = .vertical
        alertStackView.spacing = 16
        alertStackView.distribution = .fill
        alertStackView.alignment = .fill
        
        button.setTitleColor(TomeLinkColor.background, for: .normal)
        button.backgroundColor = TomeLinkColor.title
        button.titleLabel?.font = TomeLinkFont.title
    }
    
    func configureHierarchy() {
        view.addSubviews(deemBackgroundView, alertBackgroundView)
        alertBackgroundView.addSubviews(alertStackView, button)
    }
    
    func configureConstraints() {
        
        deemBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        alertBackgroundView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(32)
        }
        
        alertStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(16)
        }
        
        button.snp.makeConstraints { make in
            make.top.equalTo(alertStackView.snp.bottom).offset(26)
            make.bottom.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }
    }
}

extension PopupViewController {
    
    struct Configuration {
        let message: String
        let buttonTitle: String
        
        static func networkMonitoring() -> Configuration {
            return Configuration(message: "네트워크 연결이 일시적으로 원활하지 않습니다.\n데이터 또는 Wi-Fi 연결 상태를 확인해주세요.", buttonTitle: "확인")
        }
    }
}
