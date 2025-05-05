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
    
    private let viewModel: ReadingEditViewModel
    private let eventReceiver: any OutputEventEmittable
    private let disposeBag = DisposeBag()
    
    private var contentDate: String?
    
    // LifeCycle
    init(viewModel: ReadingEditViewModel, eventReceiver: any OutputEventEmittable) {
        self.viewModel = viewModel
        self.eventReceiver = eventReceiver
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
        
        let input = ReadingEditViewModel.Input(tapDoneButton: doneButton.rx.tap,
                                               currentPage: pageTextField.rx.text.orEmpty,
                                               startedAt: datePicker.rx.date)
        let output = viewModel.transform(input: input)
        
        output.doneAddingReading
            .drive(with: self, onNext: { owner, _ in
                
                owner.eventReceiver.outputEvent.accept(.reloadTrigger)
                owner.rx.dismiss.onNext(Void())
            })
            .disposed(by: disposeBag)
        
        output.currentPage
            .map{ String($0) }
            .drive(pageTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.startedAt
            .drive(datePicker.rx.date)
            .disposed(by: disposeBag)
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
        doneButtonConfig.title = "시작"
        doneButtonConfig.baseForegroundColor = TomeLinkColor.background
        doneButtonConfig.baseBackgroundColor = TomeLinkColor.title
        doneButton.configuration = doneButtonConfig
        
        let languge = Locale.preferredLanguages.first ?? "ko_KR"
        datePicker.locale = Locale(identifier: languge)
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
