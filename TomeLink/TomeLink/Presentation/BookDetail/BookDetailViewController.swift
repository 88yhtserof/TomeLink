//
//  BookDetailViewController.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/7/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class BookDetailViewController: UIViewController {
    
    // View
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    private let favoriteBarButtonItem = UIBarButtonItem(customView: FavoriteButton())
    fileprivate let loadingView = LoadingView()
    
    // Properties
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private let disposeBag = DisposeBag()
    private let viewModel: BookDetailViewModel
    
    // Observable - Observer
    fileprivate let itemSelectedRelay = PublishRelay<Int>()
    
    // LifeCycle
    init(viewModel: BookDetailViewModel) {
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
        configureDataSource()
        bind()
        
    }
    
    private func bind() {
        
        let input = BookDetailViewModel.Input()
        let output = viewModel.transform(input: input)
        
        
        output.book
            .compactMap{ $0 }
            .drive(with: self) { owner, book in
                owner.updateSnapshot(thumbnail: book.thumbnailURL)
                owner.updateSnapshot(bookInfo: book)
                owner.updateSnapshot(platformList: [book.detailURL])
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .withUnretained(self)
            .compactMap { owner, indexPath in
                return owner.dataSource.itemIdentifier(for: indexPath)
            }
            .compactMap { item in
                
                switch item {
                case .platforms(let url):
                    let bookDetailWebViewModel = BookDetailWebViewModel(url: url)
                    let bookDetailWebVC = BookDetailWebViewController(viewModel: bookDetailWebViewModel)
                    return bookDetailWebVC
                default:
                    return nil
                }
            }
            .bind(to: rx.pushViewController)
            .disposed(by: disposeBag)
    }
}

//MARK: - Configuration
private extension BookDetailViewController {
    
    func configureView() {
        view.backgroundColor = TomeLinkColor.background
        
        navigationItem.rightBarButtonItem = favoriteBarButtonItem
        
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
        
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
extension BookDetailViewController {
    
    func layout() -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        configuration.interSectionSpacing = 15
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
    }
    
    func sectionProvider(sectionIndex: Int, layoutEnvironment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        guard let section = Section(rawValue: sectionIndex) else {
            fatalError("Could not find section")
        }
        switch section {
        case .thumbnail:
            return sectionForThumbnail()
        case .bookInfo:
            return sectionForDramaInfo()
        case .platforms:
            return sectionForStreamingPlatform()
        }
    }
    
    func sectionForThumbnail() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(180))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: 0, trailing: spacing)
        return section
    }
    
    func sectionForDramaInfo() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: spacing)
        return section
    }
    
    func sectionForStreamingPlatform() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: spacing)
        return section
    }
    
    func titleBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: TitleSupplementaryView.elementKind, alignment: .top)
    }
}

//MARK: - CollectionView DataSource
private extension BookDetailViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section: Int, CaseIterable {
        case thumbnail
        case bookInfo
        case platforms
    }
    
    enum Item: Hashable {
        case thumbnail(URL?)
        case bookInfo(Book)
        case platforms(URL?)
    }
    
    func configureDataSource() {
        let thumbnailCellRegistration = UICollectionView.CellRegistration(handler: thumbnailCellRegistrationHandler)
        let bookInfoCellRegistration = UICollectionView.CellRegistration(handler: bookInfoCellRegistrationHandler)
        let platformCellRegistration = UICollectionView.CellRegistration(handler: platformCellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .thumbnail(let value):
                return collectionView.dequeueConfiguredReusableCell(using: thumbnailCellRegistration, for: indexPath, item: value)
            case .bookInfo(let value):
                return collectionView.dequeueConfiguredReusableCell(using: bookInfoCellRegistration, for: indexPath, item: value)
            case .platforms(let value):
                return collectionView.dequeueConfiguredReusableCell(using: platformCellRegistration, for: indexPath, item: value)
            }
        })
        
        createSnapshot()
        collectionView.dataSource = dataSource
    }
    
    // Registration Handler
    func thumbnailCellRegistrationHandler(cell: ThumbnailCollectionViewCell, indexPath: IndexPath, item: URL?) {
        cell.configure(with: item)
    }
    
    func bookInfoCellRegistrationHandler(cell: BookInfoCollectionViewCell, indexPath: IndexPath, item: Book) {
        cell.configure(with: item)
    }
    
    func platformCellRegistrationHandler(cell: PlatformCollectionViewCell, indexPath: IndexPath, item: URL?) {
        cell.configure(with: item)
    }
    
    func titleSupplementaryRegistrationHandler(supplementaryView: TitleSupplementaryView, string: String, indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Could not find section")
        }
        
        switch section {
        case .bookInfo:
            supplementaryView.configure(with: "작품 정보")
        default:
            break
        }
    }
    
    // Snapshot
    func createSnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func updateSnapshot(thumbnail value: URL?) {
        
        let items = [Item.thumbnail(value)]
        
        snapshot.appendItems(items, toSection: .thumbnail)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func updateSnapshot(bookInfo value: Book) {
        
        let items = [Item.bookInfo(value)]
        
        snapshot.appendItems(items, toSection: .bookInfo)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func updateSnapshot(platformList value: [URL?]) {
        
        let items = value.map{ Item.platforms($0) }
        
        snapshot.appendItems(items, toSection: .platforms)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}

//MARK: - Reactive
extension Reactive where Base: BookDetailViewController {
    
    var updateSnapshotWithThumbnail: Binder<URL?> {
        return Binder(base) { base, value in
            base.updateSnapshot(thumbnail: value)
        }
    }
    
    var updateSnapshotWithDramaInfo: Binder<Book> {
        return Binder(base) { base, value in
            base.updateSnapshot(bookInfo: value)
        }
    }
    
    var updateSnapshotWithStreamingPlatform: Binder<[URL?]> {
        return Binder(base) { base, list in
            base.updateSnapshot(platformList: list)
        }
    }
}
