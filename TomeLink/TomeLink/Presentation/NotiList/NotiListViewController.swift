//
//  NotiListViewController.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/1/25.
//

import UIKit

import RxSwift
import RxCocoa

final class NotiListViewController: UIViewController {
    
    // view
    private let allNotiSettingView = NotificationSettingView()
    private let recommendNotiSettingView = NotificationSettingView()
    private lazy var settingStackView = UIStackView(arrangedSubviews: [allNotiSettingView, recommendNotiSettingView])
    
    private let emptyLabel = UILabel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout())
    
    // property
    private let viewModel: NotiListViewModel
    private var dataSource: DataSource!
    
    private let disposeBag = DisposeBag()
    
    // initializer
    init(viewModel: NotiListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureConstraints()
        configureView()
        configureDataSource()
        
        bind()
    }
    
    // bind
    func bind() {
        
        let input = NotiListViewModel.Input(viewWillAppear: rx.viewWillAppear,
                                            didAllNotiToggle: allNotiSettingView.rx.isOn,
                                            didRecommendNotiToggle: recommendNotiSettingView.rx.isOn,
                                            didItemSelect: collectionView.rx.itemSelected)
        let output = viewModel.transform(input: input)
        
        output.book
            .compactMap{ $0 }
            .drive(with: self) { owner, book in
                
                let networkMonitor = NetworkMonitorManager.shared
                let networkStatusUseCase = DefaultObserveNetworkStatusUseCase(monitor: networkMonitor)
                let bookDetailViewModel = BookDetailViewModel(book: book, networkStatusUseCase: networkStatusUseCase)
                let vc = BookDetailViewController(viewModel: bookDetailViewModel)
                
                owner.rx.pushViewController.onNext(vc)
            }
            .disposed(by: disposeBag)
        
        output.notiList
            .drive(with: self) { owner, items in
                owner.updateSnapshot(with: items)
            }
            .disposed(by: disposeBag)
        
        output.emptySearchResult
            .drive(with: self) { owner, message in
                owner.emptyLabel.rx.isHidden.onNext(false)
                owner.emptyLabel.rx.text.onNext(message)
                owner.collectionView.rx.isHidden.onNext(true)
            }
            .disposed(by: disposeBag)
        
        output.isAllNotiOn
            .drive(allNotiSettingView.rx.isOn)
            .disposed(by: disposeBag)
        
        output.isRecommendNotiOn
            .drive(recommendNotiSettingView.rx.isOn)
            .disposed(by: disposeBag)
    }
}

//MARK: - Configuration
private extension NotiListViewController {
    
    func configureView() {
        view.backgroundColor = TomeLinkColor.background
        navigationItem.title = "알림"
        
        allNotiSettingView.title = "전체 공지 알림"
        recommendNotiSettingView.title = "도서 추천 알림"
        
        settingStackView.axis = .vertical
        settingStackView.distribution = .fillEqually
        settingStackView.spacing = 8
        settingStackView.backgroundColor = .tomelinkWhite
        
        emptyLabel.font = TomeLinkFont.title
        emptyLabel.textColor = .tomelinkGray
        emptyLabel.isHidden = true
        
        collectionView.backgroundColor = .white
        collectionView.bounces = false
    }
    
    func configureHierarchy() {
        view.addSubviews(settingStackView, emptyLabel, collectionView)
    }
    
    func configureConstraints() {
        
        settingStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(settingStackView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(settingStackView.snp.bottom).offset(8)
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

//MARK: - CollectionView Layout
private extension NotiListViewController {
    
    func listLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

//MARK: - Type
extension NotiListViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section {
        case notifications
    }
    
    typealias Item = IdentifiableItem<NotificationItem>
}

//MARK: - CollectionView DataSource
private extension NotiListViewController {
    
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistraionHandler)
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        updateSnapshot(with: [])
        collectionView.dataSource = dataSource
    }
    
    func cellRegistraionHandler(cell: NotiListCollectionViewCell, indexPath: IndexPath, item: Item) {
        cell.configure(with: item.item)
    }
    
    func updateSnapshot(with items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.notifications])
        snapshot.appendItems(items)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}
