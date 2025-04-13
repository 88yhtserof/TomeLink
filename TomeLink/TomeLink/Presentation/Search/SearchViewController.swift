//
//  SearchViewController.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    
    fileprivate let searchBar = UISearchBar()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    fileprivate let loadingView = LoadingView()
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private let viewMdoel: SearchViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: SearchViewModel) {
        self.viewMdoel = viewModel
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
        configureDataSource()
        bind()
        configureNotification()
    }
    
    private func bind() {
        
        let selectRecentSearchesItem = PublishRelay<String>()
        let selectSearchResultsItem = PublishRelay<Book>()
        
        collectionView.rx.itemSelected
            .withUnretained(self)
            .compactMap{ $0.dataSource.itemIdentifier(for: $1) }
            .withUnretained(self)
            .map { owner, item in
                switch item {
                case .recentSearch(let keyword):
                    owner.searchBar.rx.text.onNext(keyword)
                    selectRecentSearchesItem.accept(keyword)
                case .searchResult(let book):
                    selectSearchResultsItem.accept(book)
                case .empty:
                    break
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        let input = SearchViewModel.Input(willDisplayCell: collectionView.rx.willDisplayCell.map{ $0.at },
                                          selectRecentSearchesItem: selectRecentSearchesItem,
                                          selectSearchResultItem: selectSearchResultsItem,
                                          searchKeyword: searchBar.rx.text.orEmpty,
                                          tapSearchButton: searchBar.rx.searchButtonClicked,
                                          tapSearchCancelButton: searchBar.rx.cancelButtonClicked)
        let output = viewMdoel.transform(input: input)
        
        collectionView.rx.willBeginDragging
            .bind(to: rx.endEditing)
            .disposed(by: disposeBag)
        
        output.recentResearches
            .drive(rx.createRecentResults)
            .disposed(by: disposeBag)
        
        output.bookSearches
            .drive(rx.createSearchResults)
            .disposed(by: disposeBag)
        
        output.emptySearchResults
            .drive(rx.createEmptySearchResults)
            .disposed(by: disposeBag)
        
        output.paginationBookSearches
            .drive(rx.updateSearchResults)
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(loadingView.rx.showLoading)
            .disposed(by: disposeBag)

        output.isConnectedToNetwork
            .filter{ !$0 }
            .drive(with: self, onNext: { owner, _ in
                let popupViewModel = PopupViewModel(eventReceiver: owner.viewMdoel)
                let popupVC = PopupViewController(viewModel: popupViewModel)
                popupVC.configuration = PopupViewController.Configuration.networkMonitoring()
                popupVC.modalTransitionStyle = .crossDissolve
                popupVC.modalPresentationStyle = .overFullScreen
                owner.rx.present.onNext(popupVC)
            })
            .disposed(by: disposeBag)
        
        output.switchingSeletedTabBarIndex
            .drive(with: self) { owner, tabBarIndex in
                owner.tabBarController?.selectedIndex = tabBarIndex
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.textDidBeginEditing
            .map{ _ in true }
            .bind(to: rx.showCancelButton)
            .disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .bind(to: rx.endEditing)
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .withUnretained(self)
            .compactMap { owner, indexPath in
                return owner.dataSource.itemIdentifier(for: indexPath)
            }
            .compactMap { item in
                
                switch item {
                case .searchResult(let book):
                    let networkMonitor = NetworkMonitorManager.shared
                    let useCase = DefaultObserveNetworkStatusUseCase(monitor: networkMonitor)
                    let viewModel =  BookDetailViewModel(book: book, networkStatusUseCase: useCase)
                    let bookDetailVC = BookDetailViewController(viewModel: viewModel)
                    return bookDetailVC
                default:
                    return nil
                }
            }
            .bind(to: rx.pushViewController)
            .disposed(by: disposeBag)
    }
    
    // Notification
    func configureNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(favoriteButtonDidSave), name: NSNotification.Name("FavoriteButtonDidSave"), object: nil)
    }
    
    @objc func favoriteButtonDidSave(_ notification: Notification) {
        guard let message = notification.userInfo?["message"] as? String else {
            print("Failed to get saving message")
            return
        }
        self.view.makeToast(message, duration: 2.0, position: .bottom)
    }
}

//MARK: - Configuration
private extension SearchViewController {
    
    func configureView() {
        view.backgroundColor = TomeLinkColor.background
        collectionView.backgroundColor = .clear
        
        navigationItem.titleView = searchBar
        searchBar.placeholder = "제목, 저자, 출판사 검색"
        searchBar.tintColor = TomeLinkColor.title
        searchBar.showsCancelButton = false
        
        loadingView.isHidden = true
    }
    
    func configureHierarchy() {
        view.addSubviews(collectionView, loadingView)
    }
    
    func configureConstraints() {
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalTo(collectionView)
        }
    }
}

//MARK: - CollectionView Layout
private extension SearchViewController {
    
    func layout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let section = self?.snapshot.sectionIdentifiers.first else {
                fatalError("Could not find section for \(sectionIndex)")
            }
            
            switch section {
            case .recentSearches:
                return self?.sectionForRecentSearches()
            case .searchResults:
                return self?.sectionForSearchResults()
            case .empty:
                return self?.sectionForEmptySearchResults()
            }
        }
    }
    
    func sectionForRecentSearches() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(26), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(28))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing / 2.0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing / 2.0
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing / 2.0, leading: spacing, bottom: spacing / 2.0, trailing: spacing)
        section.boundarySupplementaryItems = [titleSupplementaryItem()]
        return section
        
    }
    
    func sectionForSearchResults() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing / 2.0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing / 2.0
        section.boundarySupplementaryItems = [titleSupplementaryItem()]
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing / 2.0, leading: spacing, bottom: spacing / 2.0, trailing: spacing)
        
        return section
    }
    
    func sectionForEmptySearchResults() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.9))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [titleSupplementaryItem()]
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing / 2.0, leading: spacing, bottom: spacing / 2.0, trailing: spacing)
        
        return section
    }
    
    func titleSupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(40))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: TitleSupplementaryView.elementKind, alignment: .top)
    }
}


//MARK: - CollectionView DataSource
private extension SearchViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section: Int, CaseIterable {
        case recentSearches
        case searchResults
        case empty
    }
    
    enum Item: Hashable {
        case recentSearch(String)
        case searchResult(Book)
        case empty(String)
    }
    
    func configureDataSource() {
        
        let recentSearchCellRegistration = UICollectionView.CellRegistration(handler: recentSearchesCellRegistrationHandler)
        let searchResultsCellRegistration = UICollectionView.CellRegistration(handler: searchResultsCellRegistrationHandler)
        let emptySearchResultsCellRegistration = UICollectionView.CellRegistration(handler: emptySearchResultsCellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .recentSearch(let value):
                return collectionView.dequeueConfiguredReusableCell(using: recentSearchCellRegistration, for: indexPath, item: value)
            case .searchResult(let value):
                return collectionView.dequeueConfiguredReusableCell(using: searchResultsCellRegistration, for: indexPath, item: value)
            case .empty(let value):
                return collectionView.dequeueConfiguredReusableCell(using: emptySearchResultsCellRegistration, for: indexPath, item: value)
            }
        })
        
        let headerSupplementaryProvider = UICollectionView.SupplementaryRegistration(elementKind: TitleSupplementaryView.elementKind, handler: headerSupplementaryRegistrationHandler)
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerSupplementaryProvider, for: indexPath)
        }
        
        collectionView.dataSource = dataSource
    }
    
    func recentSearchesCellRegistrationHandler(cell: RecentSearchesCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: item)
    }
    
    func searchResultsCellRegistrationHandler(cell: BookListCollectionViewCell, indexPath: IndexPath, item: Book) {
        cell.configure(with: item)
    }
    
    func emptySearchResultsCellRegistrationHandler(cell: EmptyCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: item)
    }
    
    func headerSupplementaryRegistrationHandler(supplementaryView: TitleSupplementaryView, string: String, indexPath: IndexPath) {
        guard let section = snapshot.sectionIdentifiers.first else {
            fatalError("Could not find section")
        }
        
        switch section {
        case .recentSearches:
            supplementaryView.configure(with: "최근 검색어")
        case .searchResults, .empty:
            supplementaryView.configure(with: "작품")
        }
    }
    
    func createSnapshotForRecentSearches(_ newItems: [String]) {
        let items = newItems.map{ Item.recentSearch($0) }
        
        snapshot = Snapshot()
        snapshot.appendSections([.recentSearches])
        snapshot.appendItems(items, toSection: .recentSearches)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func createSnapshotForSearchResults(_ newItems: [Book]) {
        let items = newItems.map{ Item.searchResult($0) }
        
        snapshot = Snapshot()
        snapshot.appendSections([.searchResults])
        snapshot.appendItems(items, toSection: .searchResults)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func createSnapshotForEmptySearchResults(_ newItem: String) {
        let items = [Item.empty(newItem)]
        
        snapshot = Snapshot()
        snapshot.appendSections([.empty])
        snapshot.appendItems(items, toSection: .empty)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func updateSnapshotForSearchResults(_ newItems: [Book]) {
        let items = newItems.map{ Item.searchResult($0) }
        
        snapshot.appendItems(items, toSection: .searchResults)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}

//MARK: - Reactive+
extension Reactive where Base: SearchViewController {
    
    var createRecentResults: Binder<[String]> {
        return Binder(base) { base, list in
            base.createSnapshotForRecentSearches(list)
        }
    }
    
    var createSearchResults: Binder<[Book]> {
        return Binder(base) { base, list in
            base.createSnapshotForSearchResults(list)
        }
    }
    
    var createEmptySearchResults: Binder<String> {
        return Binder(base) { base, value in
            base.createSnapshotForEmptySearchResults(value)
        }
    }
    
    var updateSearchResults: Binder<[Book]> {
        return Binder(base) { base, list in
            base.updateSnapshotForSearchResults(list)
        }
    }
    
    var showCancelButton: Binder<Bool> {
        return Binder(base) { base, value in
            base.searchBar.setShowsCancelButton(value, animated: true)
        }
    }
    
    var endEditing: Binder<Void> {
        return Binder(base) { base, _ in
            base.searchBar.searchTextField.resignFirstResponder()
            base.searchBar.setShowsCancelButton(false, animated: true)
        }
    }
}
