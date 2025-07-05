//
//  NotificationSettingView.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/4/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class NotificationSettingView: UIView {
    
    // view
    private let settingLabel = UILabel()
    fileprivate let settingSwitch = UISwitch()
    private lazy var settingStackView = UIStackView(arrangedSubviews: [settingLabel, settingSwitch])
    
    // property
    var title: String {
        get { settingLabel.text ?? "" }
        set { settingLabel.text = newValue }
    }
    
    // initializer
    init() {
        super.init(frame: .zero)
        
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Configuration
private extension NotificationSettingView {
    
    func configureView() {
        
        settingLabel.text = title
        settingLabel.textColor = .tomelinkBlack
        settingLabel.font = TomeLinkFont.contents
        
        settingSwitch.onTintColor = .tomelinkBlack
        
        settingStackView.axis = .horizontal
        settingStackView.distribution = .fill
        settingStackView.spacing = 8
    }
    
    func configureHierarchy() {
        
        addSubviews(settingStackView)
    }
    
    func configureConstraints() {
        
        settingStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
}

extension Reactive where Base: NotificationSettingView {
    
    var isOn: ControlProperty<Bool> {
        return base.settingSwitch.rx.isOn
    }
}
