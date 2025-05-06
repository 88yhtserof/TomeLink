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
    private let iconImageView = UIImageView()
    private let iconBarButtonItem = UIBarButtonItem()
    private let searchBarButtonItem = UIBarButtonItem()
    private lazy var categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: categoryLayout())
    private let separatorView = SeparatorView()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    // Properties
    private var categoryDataSource: CategoryDataSource!
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private let viewModel: LibraryViewModel
    private let disposeBag = DisposeBag()
    
    private let favoriteButtonDidSaveRalay = PublishRelay<Void>()
    
    // LifeCycle
    init(viewModel: LibraryViewModel) {
        self.viewModel = viewModel
        
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
        configureCategoryDataSource()
        configureDataSource()
        bind()
        configureNotification()
    }
    
    // DataBinding
    private func bind() {
        
        let tapToReadCategory = PublishRelay<Void>()
        let tapReadingCategory = PublishRelay<Void>()
        let tapArchiveCategory = PublishRelay<Void>()
        
        let input = LibraryViewModel.Input(viewWillAppear: rx.viewWillAppear,
                                           tapToReadCategory: tapToReadCategory,
                                           tapReadingCategory: tapReadingCategory,
                                           tapArchiveCategory: tapArchiveCategory)
        let output = viewModel.transform(input: input)
        
        output.listToRead
            .drive(rx.createSnapshotForToRead)
            .disposed(by: disposeBag)
        
        output.listReading
            .drive(rx.createSnapshotForReading)
            .disposed(by: disposeBag)
        
        output.listArchive
            .drive(rx.createSnapshotForArchive)
            .disposed(by: disposeBag)
        
        output.emptyList
            .drive(rx.createSnapshotForEmpty)
            .disposed(by: disposeBag)
        
        
        // category
        categoryCollectionView.rx.itemSelected
            .compactMap{ CategoryItem(rawValue: $0.row) }
            .bind(with: self) { owner, category in
                
                switch category {
                case .toRead:
                    tapToReadCategory.accept(Void())
                case .reading:
                    tapReadingCategory.accept(Void())
                case .archive:
                    tapArchiveCategory.accept(Void())
                }
            }
            .disposed(by: disposeBag)
        
        
        // library
        collectionView.rx.itemSelected
            .withUnretained(self)
            .compactMap { owner, indexPath in
                return owner.dataSource.itemIdentifier(for: indexPath)
            }
            .bind(with: self) { owner, item in
                
                switch item {
                case .toRead(let book):
                    let networkMonitor = NetworkMonitorManager.shared
                    let useCase = DefaultObserveNetworkStatusUseCase(monitor: networkMonitor)
                    let viewModel =  BookDetailViewModel(book: book, networkStatusUseCase: useCase)
                    let bookDetailVC = BookDetailViewController(viewModel: viewModel)
                    owner.rx.pushViewController.onNext(bookDetailVC)
                case .reading(let reading):
                    let repotitory = ReadingRepository()
                    let readingEditViewModel = ReadingEditViewModel(book: reading.book, repository: repotitory)
                    
                    let readingEditVC = ReadingEditViewController(viewModel: readingEditViewModel, eventReceiver: owner.viewModel)
                    if let sheet = readingEditVC.sheetPresentationController {
                        sheet.detents = [.small()]
                        sheet.prefersGrabberVisible = true
                    }
                    owner.rx.present.onNext(readingEditVC)
                case .archive:
                    break
                default:
                    break
                }
            }
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
        
        favoriteButtonDidSaveRalay.accept(Void())
        self.view.makeToast(message, duration: 1.5, position: .bottom)
    }
}

//MARK: - Configuration
private extension LibraryViewController {
    
    func configureView() {
        view.backgroundColor = TomeLinkColor.background
        
        iconImageView.image = UIImage(named: "TomeLink_Icon_Text")
        iconImageView.contentMode = .scaleAspectFill
        iconBarButtonItem.customView = iconImageView
        navigationItem.leftBarButtonItem = iconBarButtonItem
        
        searchBarButtonItem.image = UIImage(systemName: "line.3.horizontal")
//        navigationItem.rightBarButtonItem = searchBarButtonItem
        
        categoryCollectionView.backgroundColor = TomeLinkColor.background
        categoryCollectionView.isScrollEnabled = false
        
        collectionView.backgroundColor = TomeLinkColor.background
    }
    
    func configureHierarchy() {
        view.addSubviews(categoryCollectionView, separatorView, collectionView)
    }
    
    func configureConstraints() {
        
        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(130)
            make.height.equalTo(41)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(40)
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
            case .archive:
                return self.sectionForArchive()
            case .empty:
                return self.sectionForEmpty()
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
        let height: CGFloat = 240
        
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
    
    func sectionForArchive() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: 0, bottom: spacing, trailing: 0)
        
        return section
    }
    
    func sectionForEmpty() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.9))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing / 2.0, leading: spacing, bottom: spacing / 2.0, trailing: spacing)
        
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
    
    enum CategoryItem: Int, CaseIterable {
        case toRead
        case reading
        case archive
        
        var title: String {
            switch self {
            case .toRead:
                return "읽고 싶은 도서"
            case .reading:
                return "독서 진행률 %"
            case .archive:
                return "독서 기록"
            }
        }
    }
    
    enum Section: Int, CaseIterable {
        case toRead
        case reading
        case archive
        case empty
    }
    
    enum Item: Hashable {
        case toRead(Book)
        case reading(Reading)
        case archive([Archive])
        case empty(String)
    }
    
    func configureCategoryDataSource() {
        
        let categoryCellRegistration = UICollectionView.CellRegistration(handler: catergoryCellRegistrationHandler)
        
        categoryDataSource = CategoryDataSource(collectionView: categoryCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: categoryCellRegistration, for: indexPath, item: itemIdentifier.title)
        })
        
        createSnapshotForCategory()
        categoryCollectionView.dataSource = categoryDataSource
    }
    
    func configureDataSource() {
        
        let toReadCellRegistration = UICollectionView.CellRegistration(handler: toReadCellRegistrationHandler)
        let readingCellRegistration = UICollectionView.CellRegistration(handler: readingCellRegistrationHandler)
        let readCellRegistration = UICollectionView.CellRegistration(handler: archiveCellRegistrationHandler)
        let emptySearchResultsCellRegistration = UICollectionView.CellRegistration(handler: emptySearchResultsCellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .toRead(let value):
                return collectionView.dequeueConfiguredReusableCell(using: toReadCellRegistration, for: indexPath, item: value)
            case .reading(let value):
                return collectionView.dequeueConfiguredReusableCell(using: readingCellRegistration, for: indexPath, item: value)
            case .archive(let value):
                return collectionView.dequeueConfiguredReusableCell(using: readCellRegistration, for: indexPath, item: value)
            case .empty(let value):
                return collectionView.dequeueConfiguredReusableCell(using: emptySearchResultsCellRegistration, for: indexPath, item: value)
            }
        })
        
        createSnapshotForToRead([])
        collectionView.dataSource = dataSource
    }
    
    func catergoryCellRegistrationHandler(cell: CategoryCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: (item, indexPath.item == 0))
        cell.isCategorySelected = indexPath.item == 0
    }
    
    func toReadCellRegistrationHandler(cell: LibraryThumbnailCollectionViewCell, indexPath: IndexPath, item: Book) {
        cell.configure(with: item)
    }
    
    func readingCellRegistrationHandler(cell: LibraryProgressCollectionViewCell, indexPath: IndexPath, item: Reading) {
        cell.configure(with: item)
    }
    
    func archiveCellRegistrationHandler(cell: LibraryCalendarCollectionViewCell, indexPath: IndexPath, item: [Archive]) {
        cell.configure(with: item)
        
        cell.calendarView.rx.selectedBooks
            .map { (date, books) in
                let archiveRepository = ArchiveRepository()
                let calendarDetailViewModel = CalendarDetailViewModel(date: date, archiveRepository: archiveRepository)
                return CalendarDetailViewController(viewModel: calendarDetailViewModel)
            }
            .bind(to: rx.pushViewController)
            .disposed(by: disposeBag)
        
    }
    
    func emptySearchResultsCellRegistrationHandler(cell: EmptyCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: item)
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
    
    func createSnapshotForReading(_ newItems: [Reading]) {
        let items = newItems.map{ Item.reading($0) }
        
        snapshot = Snapshot()
        snapshot.deleteSections(Section.allCases.filter{ $0 != .reading })
        snapshot.appendSections([.reading])
        snapshot.appendItems(items, toSection: .reading)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func createSnapshotForArchive(_ newItems: [Archive]) {
        let items = [ Item.archive(newItems) ]
        
        snapshot = Snapshot()
        snapshot.deleteSections(Section.allCases.filter{ $0 != .archive })
        snapshot.appendSections([.archive])
        snapshot.appendItems(items, toSection: .archive)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func createSnapshotForEmpty(_ newItem: String) {
        let items = [Item.empty(newItem)]
        
        snapshot = Snapshot()
        snapshot.appendSections([.empty])
        snapshot.appendItems(items, toSection: .empty)
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
    
    var createSnapshotForReading: Binder<[Reading]> {
        return Binder(base) { base, list in
            base.createSnapshotForReading(list)
        }
    }
    
    var createSnapshotForArchive: Binder<[Archive]> {
        return Binder(base) { base, list in
            base.createSnapshotForArchive(list)
        }
    }
    
    var createSnapshotForEmpty: Binder<String> {
        return Binder(base) { base, value in
            base.createSnapshotForEmpty(value)
        }
    }
}
