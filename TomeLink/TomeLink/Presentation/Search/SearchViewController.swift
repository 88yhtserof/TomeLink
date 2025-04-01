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

class SearchViewController: UIViewController {
    
    private let searchController = UISearchController()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private let disposeBag = DisposeBag()
    private let viewMdoel = SearchViewModel()
    
    private let recentSearchDeleteRelay = PublishRelay<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureConstraints()
        configureView()
        configureDataSource()
        bind()
    }
    
    private func bind() {
        
        let input = SearchViewModel.Input(searchKeyword: searchController.searchBar.rx.text.orEmpty,
                                          tapSearchButton: searchController.searchBar.rx.searchButtonClicked,
                                          tapSearchCancelButton: searchController.searchBar.rx.cancelButtonClicked,
                                          deleteRecentSearch: recentSearchDeleteRelay)
        let output = viewMdoel.transform(input: input)
        
        collectionView.rx.willBeginDragging
            .bind(to: searchController.searchBar.rx.endEditing)
            .disposed(by: disposeBag)
        
        output.recentResearches
            .drive(rx.updateRecentResults)
            .disposed(by: disposeBag)
        
        output.bookSearches
            .drive(rx.updateSearchResults)
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.searchButtonClicked
            .bind(with: self) { owner, _ in
                owner.searchController.searchBar.text = nil
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Configuration
private extension SearchViewController {
    
    func configureView() {
        view.backgroundColor = .white
        
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "제목, 저자, 출판사 검색"
        searchController.searchBar.tintColor = TomeLinkColor.point
        searchController.automaticallyShowsCancelButton = true
    }
    
    func configureHierarchy() {
        view.addSubviews(collectionView)
    }
    
    func configureConstraints() {
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
                return self?.sectionForRecentSearches(layoutEnvironment)
            case .searchResults:
                return self?.sectionForSearchResults(layoutEnvironment)
            }
        }
    }
    
    func sectionForRecentSearches(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        section.boundarySupplementaryItems = [titleSupplementaryItem()]
        return section
    }
    
    func sectionForSearchResults(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(130))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [titleSupplementaryItem()]
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
    }
    
    enum Item: Hashable {
        case recentSearch(String)
        case searchResult(Book)
    }
    
    func configureDataSource() {
        
        let recentSearchCellRegistration = UICollectionView.CellRegistration(handler: recentSearchesCellRegistrationHandler)
        let searchResultsCellRegistration = UICollectionView.CellRegistration(handler: searchResultsCellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .recentSearch(let value):
                return collectionView.dequeueConfiguredReusableCell(using: recentSearchCellRegistration, for: indexPath, item: value)
            case .searchResult(let value):
                return collectionView.dequeueConfiguredReusableCell(using: searchResultsCellRegistration, for: indexPath, item: value)
            }
        })
        
        let headerSupplementaryProvider = UICollectionView.SupplementaryRegistration(elementKind: TitleSupplementaryView.elementKind, handler: headerSupplementaryRegistrationHandler)
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerSupplementaryProvider, for: indexPath)
        }
        
        collectionView.dataSource = dataSource
    }
    
    func recentSearchesCellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, item: String) {
        var contentConfig = UIListContentConfiguration.cell()
        contentConfig.text = item
        let backgroundConfiguration = UIBackgroundConfiguration.clear()
        cell.contentConfiguration = contentConfig
        cell.backgroundConfiguration = backgroundConfiguration
        
        let deleteButton = UIButton()
        deleteButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        deleteButton.tintColor = TomeLinkColor.subtitle
        
        deleteButton.rx.tap
            .map{ item }
            .bind(to: recentSearchDeleteRelay)
            .disposed(by: disposeBag)
        
        let deleteAccessory = UICellAccessory.CustomViewConfiguration(customView: deleteButton, placement: .trailing(displayed: .always))
        cell.accessories = [.customView(configuration: deleteAccessory)]
    }
    
    func searchResultsCellRegistrationHandler(cell: BookListCollectionViewCell, indexPath: IndexPath, item: Book) {
        cell.configure(with: item)
    }
    
    func headerSupplementaryRegistrationHandler(supplementaryView: TitleSupplementaryView, string: String, indexPath: IndexPath) {
        guard let section = snapshot.sectionIdentifiers.first else {
            fatalError("Could not find section")
        }
        
        switch section {
        case .recentSearches:
            supplementaryView.configure(with: "최근 검색어")
        case .searchResults:
            supplementaryView.configure(with: "작품")
        }
    }
    
    func updateSnapshotForRecentSearches(_ newItems: [String]) {
        let items = newItems.map{ Item.recentSearch($0) }
        
        snapshot = Snapshot()
        snapshot.appendSections([.recentSearches])
        snapshot.appendItems(items, toSection: .recentSearches)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func updateSnapshotForSearchResults(_ newItems: [Book]) {
        let items = newItems.map{ Item.searchResult($0) }
        
        snapshot = Snapshot()
        snapshot.appendSections([.searchResults])
        snapshot.appendItems(items, toSection: .searchResults)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension Reactive where Base: SearchViewController {
    
    var updateRecentResults: Binder<[String]> {
        return Binder(base) { base, list in
            base.updateSnapshotForRecentSearches(list)
        }
    }
    
    var updateSearchResults: Binder<[Book]> {
        return Binder(base) { base, list in
            base.updateSnapshotForSearchResults(list)
        }
    }
}
