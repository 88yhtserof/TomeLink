//
//  LibraryViewController.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/4/25.
//

import UIKit

import RxSwift
import RxCocoa

final class LibraryViewController: UIViewController {
    
    // Views
    private let iconBarButtonItem = UIBarButtonItem()
    private let searchBarButtonItem = UIBarButtonItem()
    private lazy var categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: categoryLayout())
    private let separatorView = SeparatorView()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    // Properties
    private var categoryDataSource: CategoryDataSource!
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private let disposeBag = DisposeBag()
    
    // LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureHierarchy()
        configureConstraints()
        configureView()
        configureCategoryDataSource()
        configureDataSource()
        bind()
    }
    
    // DataBinding
    private func bind() {
        
        categoryCollectionView.rx.itemSelected
            .withUnretained(self)
            .filter{ owner, indexPath in
                guard let currentCell = owner.categoryCollectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else {
                    return false
                }
                return !currentCell.isCategorySelected
            }
            .compactMap{ owner, indexPath in
                owner.categoryCollectionView.visibleCells
                    .compactMap{ cell in
                        cell as? CategoryCollectionViewCell
                    }
                    .filter{ $0.isCategorySelected }
                    .forEach { cell in
                        cell.isCategorySelected = false
                    }
                    
                if let selectedCell = owner.categoryCollectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
                    selectedCell.isCategorySelected = true
                }
                
                return owner.categoryDataSource.itemIdentifier(for: indexPath)
            }
            .bind(with: self) { (owner, category) in
                switch category {
                case .toRead:
                    print("toRead")
                    let thumbnails = ["https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5450099%3Ftimestamp%3D20250319144818", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6458653%3Ftimestamp%3D20250208152926", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F4751039%3Ftimestamp%3D20190302121725", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F540501%3Ftimestamp%3D20241120115010", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6633286%3Ftimestamp%3D20250208153008", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6861926%3Ftimestamp%3D20250401155537", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6062691%3Ftimestamp%3D20240528172936", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F540854%3Ftimestamp%3D20241122114045", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6516766%3Ftimestamp%3D20241219152327", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6715922%3Ftimestamp%3D20241029171820", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F540832%3Ftimestamp%3D20241018113939"]
                    
                    owner.createSnapshotForToRead(thumbnails)
                case .reading:
                    owner.createSnapshotForReading(["-title1", "-title2", "-title3", "-title4", "-title5", "-title6", "-title7", "-title8", "-title9", "-title10"])
                case .read:
                    owner.createSnapshotForRead(["`title1"])
                }
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Configuration
private extension LibraryViewController {
    
    func configureView() {
        view.backgroundColor = TomeLinkColor.background
        
        let iconImageView = UIImageView(image: UIImage(named: "TomeLink_Icon_Text"))
        iconImageView.sizeThatFits(CGSize(width: 182, height: 29))
        iconBarButtonItem.customView = iconImageView
        navigationItem.leftBarButtonItem = iconBarButtonItem
        
        searchBarButtonItem.image = UIImage(systemName: "line.3.horizontal")
        navigationItem.rightBarButtonItem = searchBarButtonItem
        
        categoryCollectionView.backgroundColor = TomeLinkColor.background
        categoryCollectionView.isScrollEnabled = false
        
        collectionView.backgroundColor = TomeLinkColor.background
    }
    
    func configureHierarchy() {
        view.addSubviews(categoryCollectionView, separatorView, collectionView)
    }
    
    func configureConstraints() {
        
        categoryCollectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(53)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(categoryCollectionView.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(1.0)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

//MARK: - CollectionView Layout
private extension LibraryViewController {
    
    func categoryLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 8
        let height: CGFloat = 40
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(height))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: 0, trailing: spacing)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func layout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self,
                  let section = self.snapshot.sectionIdentifiers.first else {
                fatalError("Could not access self")
            }
            
            switch section {
            case .toRead:
                return self.sectionForToRead()
            case .reading:
                return self.sectionForReading()
            case .read:
                return self.sectionForRead()
            }
        }
    }
    
    func sectionForToRead() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        let width: CGFloat = (view.frame.width - spacing * 4 ) / 3.0
        let height: CGFloat = width * (4.5 / 3.0) + 30 + 8
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 3.0), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        return section
    }
    
    func sectionForReading() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        let height: CGFloat = 200
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        return section
    }
    
    func sectionForRead() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        
        return section
    }
}

//MARK: - CollectionView DataSource
private extension LibraryViewController {
    
    typealias CategoryDataSource = UICollectionViewDiffableDataSource<CategorySection, CategoryItem>
    typealias CategorySnapshot = NSDiffableDataSourceSnapshot<CategorySection, CategoryItem>
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum CategorySection: CaseIterable {
        case library
    }
    
    enum CategoryItem: String, CaseIterable {
        case toRead = "읽고 싶은 도서"
        case reading = "독서 진행률 %"
        case read = "독서 기록"
    }
    
    enum Section: Int, CaseIterable {
        case toRead
        case reading
        case read
    }
    
    enum Item: Hashable {
        case toRead(String)
        case reading(String)
        case read(String)
    }
    
    func configureCategoryDataSource() {
        
        let categoryCellRegistration = UICollectionView.CellRegistration(handler: catergoryCellRegistrationHandler)
        
        categoryDataSource = CategoryDataSource(collectionView: categoryCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: categoryCellRegistration, for: indexPath, item: itemIdentifier.rawValue)
        })
        
        createSnapshotForCategory()
        categoryCollectionView.dataSource = categoryDataSource
    }
    
    func configureDataSource() {
        
        let toReadCellRegistration = UICollectionView.CellRegistration(handler: toReadCellRegistrationHandler)
        let readingCellRegistration = UICollectionView.CellRegistration(handler: readingCellRegistrationHandler)
        let readCellRegistration = UICollectionView.CellRegistration(handler: readCellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .toRead(let value):
                return collectionView.dequeueConfiguredReusableCell(using: toReadCellRegistration, for: indexPath, item: value)
            case .reading(let value):
                return collectionView.dequeueConfiguredReusableCell(using: readingCellRegistration, for: indexPath, item: value)
            case .read(let value):
                return collectionView.dequeueConfiguredReusableCell(using: readCellRegistration, for: indexPath, item: value)
            }
        })
        
        
        let thumbnails = ["https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5450099%3Ftimestamp%3D20250319144818", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6458653%3Ftimestamp%3D20250208152926", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F4751039%3Ftimestamp%3D20190302121725", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F540501%3Ftimestamp%3D20241120115010", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6633286%3Ftimestamp%3D20250208153008", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6861926%3Ftimestamp%3D20250401155537", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6062691%3Ftimestamp%3D20240528172936", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F540854%3Ftimestamp%3D20241122114045", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6516766%3Ftimestamp%3D20241219152327", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6715922%3Ftimestamp%3D20241029171820", "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F540832%3Ftimestamp%3D20241018113939"]
        
        createSnapshotForToRead(thumbnails)
        collectionView.dataSource = dataSource
    }
    
    func catergoryCellRegistrationHandler(cell: CategoryCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: (item, indexPath.item == 0))
        cell.isCategorySelected = indexPath.item == 0
    }
    
    func toReadCellRegistrationHandler(cell: LibraryThumbnailCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: item)
    }
    
    func readingCellRegistrationHandler(cell: LibraryProgressCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: item)
    }
    
    func readCellRegistrationHandler(cell: LibraryCalendarCollectionViewCell, indexPath: IndexPath, item: String) {
        
    }
    
    func createSnapshotForCategory() {
        let items = CategoryItem.allCases
        
        var snapshot = CategorySnapshot()
        snapshot.appendSections(CategorySection.allCases)
        snapshot.appendItems(items)
        categoryDataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func createSnapshotForToRead(_ newItems: [String]) {
        let items = newItems.map{ Item.toRead($0) }
        
        snapshot = Snapshot()
        snapshot.deleteSections(Section.allCases.filter{ $0 != .toRead })
        snapshot.appendSections([.toRead])
        snapshot.appendItems(items, toSection: .toRead)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func createSnapshotForReading(_ newItems: [String]) {
        let items = newItems.map{ Item.reading($0) }
        
        snapshot = Snapshot()
        snapshot.deleteSections(Section.allCases.filter{ $0 != .reading })
        snapshot.appendSections([.reading])
        snapshot.appendItems(items, toSection: .reading)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func createSnapshotForRead(_ newItems: [String]) {
        let items = newItems.map{ Item.read($0) }
        
        snapshot = Snapshot()
        snapshot.deleteSections(Section.allCases.filter{ $0 != .read })
        snapshot.appendSections([.read])
        snapshot.appendItems(items, toSection: .read)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}

//MARK: - Reactive+
extension Reactive where Base: LibraryViewController {
    
    var createSnapshotForToRead: Binder<[String]> {
        return Binder(base) { base, list in
            base.createSnapshotForToRead(list)
        }
    }
    
    var createSnapshotForReading: Binder<[String]> {
        return Binder(base) { base, list in
            base.createSnapshotForReading(list)
        }
    }
    
    var createSnapshotForRead: Binder<[String]> {
        return Binder(base) { base, list in
            base.createSnapshotForRead(list)
        }
    }
}
