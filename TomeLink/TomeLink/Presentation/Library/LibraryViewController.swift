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
                    let books = [Book(authors: ["제인 오스틴"], contents: "셰익스피어의 뒤를 이어 ‘지난 천 년간 최고의 문학가’로 꼽힌 제인 오스틴 결혼을 마주한 여성들이 헤쳐 나가야 하는 현실적인 난관, 그리고 애정이라는 조건을 예리하게 묘파한 고전 중의 고전  “제가 장담하는데 당신은 저한테서 좋은 점을 하나도 찾지 못했어요. 그렇지만 사랑에 빠지면 그런 거야 문제될 것 없을 테지요.”  완전히 새로운 번역, 원문에 충실한 정확한 번역으로 만나는 『오만과 편견』", publicationDate: Date(), isbn: "8937460882 9788937460883", price: 13000, publisher: "민음사", salePrice: 11700, status: "정상판매", thumbnailURL: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F540854%3Ftimestamp%3D20241122114045"), title: "오만과 편견", translators: ["전승희"], detailURL: URL(string: "https://search.daum.net/search?w=bookpage&bookId=540854&q=%EC%98%A4%EB%A7%8C%EA%B3%BC+%ED%8E%B8%EA%B2%AC"))]
                    
                    owner.createSnapshotForToRead(books)
                case .reading:
                    owner.createSnapshotForReading(["-title1", "-title2", "-title3", "-title4", "-title5", "-title6", "-title7", "-title8", "-title9", "-title10"])
                case .read:
                    owner.createSnapshotForRead(["`title1"])
                }
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .withUnretained(self)
            .compactMap { owner, indexPath in
                return owner.dataSource.itemIdentifier(for: indexPath)
            }
            .compactMap { item in
                
                switch item {
                case .toRead(let book):
                    let viewModel =  BookDetailViewModel(book: book)
                    let bookDetailVC = BookDetailViewController(viewModel: viewModel)
                    return bookDetailVC
                case .reading:
                    return nil
                case .read:
                    return nil
                }
            }
            .bind(to: rx.pushViewController)
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
            make.height.equalTo(45)
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
        let height: CGFloat = 34
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(height))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: spacing)
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
        case toRead(Book)
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
        
        
        let books = [Book(authors: ["제인 오스틴"], contents: "셰익스피어의 뒤를 이어 ‘지난 천 년간 최고의 문학가’로 꼽힌 제인 오스틴 결혼을 마주한 여성들이 헤쳐 나가야 하는 현실적인 난관, 그리고 애정이라는 조건을 예리하게 묘파한 고전 중의 고전  “제가 장담하는데 당신은 저한테서 좋은 점을 하나도 찾지 못했어요. 그렇지만 사랑에 빠지면 그런 거야 문제될 것 없을 테지요.”  완전히 새로운 번역, 원문에 충실한 정확한 번역으로 만나는 『오만과 편견』", publicationDate: Date(), isbn: "8937460882 9788937460883", price: 13000, publisher: "민음사", salePrice: 11700, status: "정상판매", thumbnailURL: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F540854%3Ftimestamp%3D20241122114045"), title: "오만과 편견", translators: ["전승희"], detailURL: URL(string: "https://search.daum.net/search?w=bookpage&bookId=540854&q=%EC%98%A4%EB%A7%8C%EA%B3%BC+%ED%8E%B8%EA%B2%AC"))]
        
        
        createSnapshotForToRead(books)
        collectionView.dataSource = dataSource
    }
    
    func catergoryCellRegistrationHandler(cell: CategoryCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: (item, indexPath.item == 0))
        cell.isCategorySelected = indexPath.item == 0
    }
    
    func toReadCellRegistrationHandler(cell: LibraryThumbnailCollectionViewCell, indexPath: IndexPath, item: Book) {
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
    
    func createSnapshotForToRead(_ newItems: [Book]) {
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
    
    var createSnapshotForToRead: Binder<[Book]> {
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
