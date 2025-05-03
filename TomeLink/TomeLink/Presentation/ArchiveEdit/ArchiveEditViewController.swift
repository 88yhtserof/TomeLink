//
//  ArchiveEditViewController.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/29/25.
//

import UIKit

import RxSwift
import RxCocoa

final class ArchiveEditViewController: UIViewController {
    
    private let noteLabel = UILabel()
    private let noteTextView = UITextView()
    private let dateLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let doneButton = UIButton()
    
    private let viewModel: ArchiveEditViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: ArchiveEditViewModel) {
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    func bind() {
        let input = ArchiveEditViewModel.Input(tapDoneButton: doneButton.rx.tap,
                                               archivedAt: datePicker.rx.date,
                                               note: noteTextView.rx.text)
        let output = viewModel.transform(input: input)
        
        output.dismiss
            .drive(rx.dismiss)
            .disposed(by: disposeBag)
        
        output.date
            .drive(datePicker.rx.date)
            .disposed(by: disposeBag)
        
        output.note
            .drive(noteTextView.rx.text)
            .disposed(by: disposeBag)
            
    }
}

//MARK: - Configuration
private extension ArchiveEditViewController {
    
    func configureView() {
        view.backgroundColor = TomeLinkColor.background
        
        noteLabel.text = "독서 기록"
        noteLabel.font = .systemFont(ofSize: 16)
        
        noteTextView.backgroundColor = .systemGray6
        noteTextView.font = .systemFont(ofSize: 16)
        noteTextView.textAlignment = .left
        noteTextView.cornerRadius()
        noteTextView.tintColor = TomeLinkColor.title
        
        dateLabel.text = "기록할 날짜"
        dateLabel.font = .systemFont(ofSize: 16)
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = TomeLinkColor.point
        
        var doneButtonConfig = UIButton.Configuration.filled()
        doneButtonConfig.title = "기록하기"
        doneButtonConfig.baseForegroundColor = TomeLinkColor.background
        doneButtonConfig.baseBackgroundColor = TomeLinkColor.title
        doneButton.configuration = doneButtonConfig
        
        let languge = Locale.preferredLanguages.first ?? "ko_KR"
        datePicker.locale = Locale(identifier: languge)
    }
    
    func configureHierarchy() {
        view.addSubviews(noteLabel, noteTextView, dateLabel, datePicker, doneButton)
    }
    
    func configureConstraints() {
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().inset(50)
            make.height.equalTo(36)
        }
        
        datePicker.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel)
            make.leading.equalTo(dateLabel.snp.trailing).offset(16)
            make.height.equalTo(32)
            make.width.greaterThanOrEqualTo(120)
        }
        
        noteLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }
        
        noteTextView.snp.makeConstraints { make in
            make.top.equalTo(noteLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        doneButton.snp.makeConstraints { make in
            make.top.equalTo(noteTextView.snp.bottom).offset(30)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).inset(-16)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
    }
}
