//
//  ReadingEditViewController.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/10/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class ReadingEditViewController: UIViewController {
    
    private let pageLabel = UILabel()
    private let pageTextField = UITextField()
    private let dateLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let doneButton = UIButton()
    
    private let disposeBag = DisposeBag()
    
    private var contentDate: String?
    
    // LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureConstraints()
        configureView()
    }
}

//MARK: - Configuration
private extension ReadingEditViewController {
    
    func configureView() {
        view.backgroundColor = TomeLinkColor.background
        
        pageLabel.text = "현재 쪽수"
        pageLabel.font = .systemFont(ofSize: 16)
        
        pageTextField.backgroundColor = .systemGray6
        pageTextField.placeholder = "1"
        pageTextField.font = .systemFont(ofSize: 16)
        pageTextField.textAlignment = .center
        pageTextField.cornerRadius()
        pageTextField.keyboardType = .numberPad
        
        dateLabel.text = "시작 날짜"
        dateLabel.font = .systemFont(ofSize: 16)
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = TomeLinkColor.point
        
        var doneButtonConfig = UIButton.Configuration.filled()
        doneButtonConfig.title = "완료"
        doneButtonConfig.baseForegroundColor = TomeLinkColor.background
        doneButtonConfig.baseBackgroundColor = TomeLinkColor.title
        doneButton.configuration = doneButtonConfig
        
        let languge = Locale.preferredLanguages.first ?? "ko_KR"
        datePicker.locale = Locale(identifier: languge)
        
        let action = UIAction { [weak self]_ in
            guard let self else { return }
            let date = self.datePicker.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd E"
            let languge = Locale.preferredLanguages.first ?? "ko_KR"
            dateFormatter.locale = Locale(identifier: languge)
            
            self.contentDate = dateFormatter.string(from: date)
        }
        datePicker.addAction(action, for: .valueChanged)
    }
    
    func configureHierarchy() {
        view.addSubviews(pageLabel, pageTextField, dateLabel, datePicker, doneButton)
    }
    
    func configureConstraints() {
        
        pageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(36)
        }
        
        pageTextField.snp.makeConstraints { make in
            make.centerY.equalTo(pageLabel)
            make.leading.equalTo(pageLabel.snp.trailing).offset(20)
            make.width.equalTo(80)
            make.height.equalTo(32)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(pageLabel)
            make.top.equalTo(pageLabel.snp.bottom).offset(16)
            make.height.equalTo(36)
        }
        
        datePicker.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel)
            make.leading.equalTo(dateLabel.snp.trailing).offset(20)
            make.height.equalTo(32)
            make.width.greaterThanOrEqualTo(120)
        }
        
        doneButton.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(30)
            make.bottom.lessThanOrEqualToSuperview().inset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
}
