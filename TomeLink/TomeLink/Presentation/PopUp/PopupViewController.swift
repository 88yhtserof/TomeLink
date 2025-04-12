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
    
    var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }
    
    var buttonTitle: String? {
        get { button.title(for: .normal) }
        set { button.setTitle(newValue, for: .normal) }
    }
    
    var buttonHandler: (() -> Void)?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureHierarchy()
        configureConstraints()
        configureView()
        bind()
    }
    
    func bind() {
        
        button.rx.tap
            .withLatestFrom(NetworkMonitorManager.shared.isConnected)
            .bind(with: self) { owner, isConnected in
                if isConnected {
                    owner.buttonHandler?()
                    owner.dismiss(animated: true)
                } else {
                    owner.view.makeToast("네트워크 연결이 일시적으로 원활하지 않습니다. 데이터 또는 Wi-Fi 연결 상태를 확인해주세요.")
                }
            }
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
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = TomeLinkColor.title
        titleLabel.textAlignment = .center
        
        messageLabel.font = .systemFont(ofSize: 14, weight: .regular)
        messageLabel.textColor = TomeLinkColor.title
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        alertStackView.axis = .vertical
        alertStackView.spacing = 16
        alertStackView.distribution = .fill
        alertStackView.alignment = .fill
        
        button.setTitleColor(TomeLinkColor.title, for: .normal)
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
