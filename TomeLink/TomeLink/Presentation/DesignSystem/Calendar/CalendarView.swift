//
//  CalendarView.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/4/25.
//

import UIKit

import SnapKit

final class CalendarView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // 특정 날짜와 이미지 URL을 매핑하는 딕셔너리
    private let dateImageMap: [String: String] = [
        "2025-04-04": "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5450099%3Ftimestamp%3D20250319144818", // 예시 URL
        "2025-04-11": "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6062691%3Ftimestamp%3D20240528172936",
        "2025-04-14": "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F540854%3Ftimestamp%3D20241122114045"
    ]
    
    private var collectionView: UICollectionView!
    private var dates: [Date] = [] // 캘린더에 표시할 날짜 배열
    private var currentMonth: Date! // 현재 표시 중인 월
    private let monthLabel = UILabel() // 현재 월 표시 레이블
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = TomeLinkColor.background
        
        // 현재 월 설정
        currentMonth = Date()
        calculateDates()
        
        // 월 표시 레이블 및 이동 버튼 설정
        setupMonthNavigation()
        
        // 요일 헤더 라벨 설정
        setupWeekdayLabels()
        
        // UICollectionView 설정
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = TomeLinkColor.background
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        addSubview(collectionView)
        
        // SnapKit을 사용한 제약 설정
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(80) // 월 이동 버튼과 요일 헤더 아래에 배치
            make.bottom.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 월 표시 레이블 및 이동 버튼 설정
    private func setupMonthNavigation() {
        // 월 표시 레이블
        monthLabel.textAlignment = .center
        monthLabel.font = .systemFont(ofSize: 18, weight: .bold)
        updateMonthLabel()
        addSubview(monthLabel)
        
        monthLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        
        // 이전 버튼
        let prevButton = UIButton(type: .system)
        prevButton.setTitleColor(TomeLinkColor.point, for: .normal)
        prevButton.setTitle("<", for: .normal)
        prevButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        prevButton.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        addSubview(prevButton)
        
        prevButton.snp.makeConstraints { make in
            make.centerY.equalTo(monthLabel)
            make.trailing.equalTo(monthLabel.snp.leading).offset(-20)
        }
        
        // 다음 버튼
        let nextButton = UIButton(type: .system)
        nextButton.setTitleColor(TomeLinkColor.point, for: .normal)
        nextButton.setTitle(">", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        addSubview(nextButton)
        
        nextButton.snp.makeConstraints { make in
            make.centerY.equalTo(monthLabel)
            make.leading.equalTo(monthLabel.snp.trailing).offset(20)
        }
    }
    
    // 현재 월 표시 업데이트
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM"
        monthLabel.text = dateFormatter.string(from: currentMonth)
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
    
    // 요일 헤더 라벨 설정
    private func setupWeekdayLabels() {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(monthLabel.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        for weekday in weekdays {
            let label = UILabel()
            label.text = weekday
            label.textAlignment = .center
            label.textColor = TomeLinkColor.subtitle
            label.font = .systemFont(ofSize: 14)
            stackView.addArrangedSubview(label)
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
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
            dates.append(date)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CalendarCollectionViewCell
        let date = dates[indexPath.item]
        
        if date == Date.distantPast {
            cell.configure(day: nil, imageUrl: nil)
        } else {
            let day = Calendar.current.component(.day, from: date)
            
            // 날짜를 "yyyy-MM-dd" 형식으로 변환
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            
            // 해당 날짜에 이미지 URL이 있는지 확인
            let imageUrlString = dateImageMap[dateString]
            cell.configure(day: day, imageUrl: imageUrlString)
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: width * 1.5) // 셀 높이를 조정
    }
}
