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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureConstraints()
        configureView()
        configureDataSource()
        bind()
    }
    
    private func bind() {
        
        collectionView.rx.willBeginDragging
            .bind(to: searchController.searchBar.rx.endEditing)
            .disposed(by: disposeBag)
        
        updateSnapshotForRecentSearches([])
//        updateSnapshotForSearchResults([])
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
            guard let section = Section(rawValue: sectionIndex) else {
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
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
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
        case searchResult(String)
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
        cell.contentConfiguration = contentConfig
        let deleteButton = UIButton()
        deleteButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        deleteButton.tintColor = TomeLinkColor.subtitle
        let deleteAccessory = UICellAccessory.CustomViewConfiguration(customView: deleteButton, placement: .trailing(displayed: .always))
        cell.accessories = [.customView(configuration: deleteAccessory)]
    }
    
    func searchResultsCellRegistrationHandler(cell: BookListCollectionViewCell, indexPath: IndexPath, item: String) {
        let book = Book(authors: ["조지오웰"], contents: "▶ 출간 이후 단 한번도 절판된 적이 없는 영원한 고전  조지 오웰의 뛰어난 창조력이 만든 최고의 걸작이 담긴 선물 같은 책!    20세기 문학의 대표적인 작품으로 ‘풍자 우화’라는 창조성이 돋보이는 《동물 농장》은 1945년 출간한 지 2주 만에 초판이 모두 매진될 정도로 큰 인기를 얻었다. 그 후, 〈타임〉지가 선정한 100대 영문 소설, 한국 문인이 선호하는 〈세계 명작 소설 100선〉에 선정될 만큼 국내외 할 것 없이 큰 사랑을 받았다. 이 소설", publicationDate: Date(), isbn: "1164453122 9791164453122", price: 1000, publisher: "더스토리", salePrice: 300, status: "정상 판매", thumbnailURL: URL(string:"https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5450099%3Ftimestamp%3D20250319144818"), title: "동물농장", translators: ["이종인"], detailURL: URL(string: "https://search.daum.net/search?w=bookpage&bookId=5450099&q=%EB%8F%99%EB%AC%BC+%EB%86%8D%EC%9E%A5%28%EC%B4%88%ED%8C%90%EB%B3%B8%29%281945%EB%85%84+%EC%98%A4%EB%A6%AC%EC%A7%80%EB%84%90+%EC%B4%88%ED%8C%90%EB%B3%B8+%ED%91%9C%EC%A7%80+%EB%94%94%EC%9E%90%EC%9D%B8%29"))
        cell.configure(with: book)
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
    
    func updateSnapshotForSearchResults(_ newItems: [String]) {
        let items = newItems.map{ Item.searchResult($0) }
        
        snapshot = Snapshot()
        snapshot.appendSections([.searchResults])
        snapshot.appendItems(items, toSection: .searchResults)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
