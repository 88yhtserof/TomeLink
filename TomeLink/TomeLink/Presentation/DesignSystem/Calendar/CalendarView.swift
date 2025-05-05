//
//  CalendarView.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/4/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class CalendarView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    private let prevButton = UIButton()
    private let nextButton = UIButton()
    private let weeklyStackView = UIStackView()
    private let monthLabel = UILabel()
    
    private var archives: [Archive] = []
    private var booksForDate: [Date: [Book]] = [:]
    private var dates: [Date] = []
    private var currentMonth: Date!
    
    private let disposeBag = DisposeBag()
    fileprivate var selectedBooks = PublishRelay<(Date, [Book])>()
    
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
    
    // Binding
    func bind(_ viewModel: CalendarViewModel) {
        
        let input = CalendarViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.archives
            .drive(with: self) { owner, list in
                owner.archives = list
            }
            .disposed(by: disposeBag)
            
        collectionView.rx.itemSelected
            .withUnretained(self)
            .compactMap { owner, indexPath in
                let date = owner.dates[indexPath.row]
                guard let books = owner.booksForDate[date] else { return nil }
                print(indexPath, date, books)
                return (date, books)
            }
            .take(1)
            .do { _ in
                print("CalendarView - collectionView.rx.itemSelected: next")
            } onDispose: {
                print("CalendarView - collectionView.rx.itemSelected: dispose")
            }
            .bind(to: selectedBooks)
            .disposed(by: disposeBag)
    }
    
    // 월 표시 레이블 및 이동 버튼 설정
    private func setupMonthNavigation() {
        // 월 표시 레이블
        monthLabel.textColor = TomeLinkColor.title
        monthLabel.textAlignment = .center
        monthLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        updateMonthLabel()
        
        // 이전 버튼
        let prevButtonImage = UIImage(systemName: "chevron.left")
        prevButton.tintColor = TomeLinkColor.title
        prevButton.setImage(prevButtonImage, for: .normal)
        prevButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        prevButton.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        
        // 다음 버튼
        let nextButtonImage = UIImage(systemName: "chevron.right")
        nextButton.tintColor = TomeLinkColor.title
        nextButton.setImage(nextButtonImage, for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
    }
    
    // 이전 월로 이동
    @objc private func prevMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
        calculateDates()
        updateMonthLabel()
        
        // 부드러운 애니메이션 적용
        UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.collectionView.reloadData()
        }, completion: nil)
    }
    
    // 다음 월로 이동
    @objc private func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
        calculateDates()
        updateMonthLabel()
        
        // 부드러운 애니메이션 적용
        UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.collectionView.reloadData()
        }, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CalendarCollectionViewCell
        let date = dates[indexPath.item]
        
        if date == Date.distantPast {
            cell.configure(day: nil, books: nil)
        } else {
            let day = TomeLinkCalendar.component(.day, from: date - 1, in: .calendar)
            print(day)
            let filteredArchives = archives
                .filter { TomeLinkCalendar.isDate($0.archivedAt, inSameDayAs: date, in: .calendar) }
                .sorted { $0.archivedAt < $1.archivedAt }
                .map{ $0.book }
            if filteredArchives.count > 0 {
                booksForDate[date] = filteredArchives
            }
            cell.configure(day: day, books: filteredArchives)
        }
        return cell
    }
    
    func layout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 7.0), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0 / 6.3))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

//MARK: - Configuration
extension CalendarView {
    
    func configureHierarchy() {
        addSubviews(monthLabel, nextButton, prevButton, weeklyStackView, collectionView)
    }
    
    func configureConstraints() {
        
        let horizontalInset: CGFloat = 16
        
        monthLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(horizontalInset)
        }
        
        prevButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.centerY.equalTo(monthLabel)
            make.trailing.equalTo(nextButton.snp.leading).offset(-16)
        }
        
        nextButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.centerY.equalTo(monthLabel)
            make.trailing.equalToSuperview().inset(horizontalInset)
        }
        
        weeklyStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(monthLabel.snp.bottom).offset(4)
            make.height.equalTo(40)
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(weeklyStackView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
    
    func configureView() {
        backgroundColor = TomeLinkColor.background
        
        // 현재 월 설정
        currentMonth = Date()
        calculateDates()
        
        // 월 표시 레이블 및 이동 버튼 설정
        setupMonthNavigation()
        
        // 요일 헤더 라벨 설정
        setupWeekdayLabels()
        
        collectionView.backgroundColor = TomeLinkColor.background
        collectionView.dataSource = self
        collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        collectionView.isScrollEnabled = false
    }
    
    // 현재 월 표시 업데이트
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM"
        monthLabel.text = dateFormatter.string(from: currentMonth)
    }
    
    // 요일 헤더 라벨 설정
    private func setupWeekdayLabels() {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        weeklyStackView.axis = .horizontal
        weeklyStackView.distribution = .fillEqually
        weeklyStackView.spacing = 0
        
        for weekday in weekdays {
            let label = UILabel()
            label.text = weekday
            label.textAlignment = .center
            label.textColor = TomeLinkColor.subtitle
            label.font = .systemFont(ofSize: 14)
            weeklyStackView.addArrangedSubview(label)
        }
    }
    
    // 캘린더 날짜 계산
    private func calculateDates() {
        dates.removeAll()
        
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // 첫 주의 빈 날짜 추가
        for _ in 1..<weekday {
            dates.append(Date.distantPast)
        }
        
        // 해당 월의 날짜 추가
        for day in 1...range.count {
            let date = calendar.date(byAdding: .day, value: day, to: firstDayOfMonth)!
            dates.append(date)
        }
    }
}

extension Reactive where Base: CalendarView {
    
    var selectedBooks: Observable<(Date, [Book])> {
        return base.selectedBooks
            .take(1)
            .do { _ in
                print("CalendarView - selectedBooks: next")
            } onDispose: {
                print("CalendarView - selectedBooks: dispose")
            }
    }
}
