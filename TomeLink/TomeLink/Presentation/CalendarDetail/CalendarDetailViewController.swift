//
//  CalendarDetailViewController.swift
//  TomeLink
//
//  Created by 임윤휘 on 5/1/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class CalendarDetailViewController: UIViewController {
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private let viewMdoel: CalendarDetailViewModel
    private let disposeBag = DisposeBag()
    private let deleteBook: PublishRelay<IndexPath> = PublishRelay<IndexPath>()
    
    init(viewModel: CalendarDetailViewModel) {
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
    }
    
    private func bind() {
        
        let input = CalendarDetailViewModel.Input(viewWillAppear: rx.viewWillAppear,
                                                  deleteBook: deleteBook.asObservable())
        let output = viewMdoel.transform(input: input)
        
        output.bookWithDateList
            .map { list in
                return list.map{ Item(archivedAt: $0.0, book: $0.1) }
            }
            .drive(rx.createSnapshot)
            .disposed(by: disposeBag)
    }
}

//MARK: - Configuration
private extension CalendarDetailViewController {
    
    func configureView() {
        view.backgroundColor = TomeLinkColor.background
        collectionView.backgroundColor = .clear
    }
    
    func configureHierarchy() {
        view.addSubviews(collectionView)
    }
    
    func configureConstraints() {
        
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
}

//MARK: - CollectionView Layout
private extension CalendarDetailViewController {
    
    func layout() -> UICollectionViewLayout {
        
        var separator = UIListSeparatorConfiguration(listAppearance: .plain)
        separator.color = TomeLinkColor.separator2
        
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .clear
        config.separatorConfiguration = separator
        
        config.trailingSwipeActionsConfigurationProvider = { indexPath in
            
            let action = UIContextualAction(style: .destructive, title: "삭제") { [weak self] action, view, completionHandler in
                self?.deleteBook.accept(indexPath)
            }
            
            return UISwipeActionsConfiguration(actions: [action])
        }
        
        return UICollectionViewCompositionalLayout { _, environment in
            
            let horizontalInset: CGFloat = 16
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: horizontalInset, bottom: 0, trailing: horizontalInset)
            return section
        }
    }
}


//MARK: - CollectionView DataSource
private extension CalendarDetailViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section: Int, CaseIterable {
        case searchResults
    }
    
    struct Item: Hashable {
        let archivedAt: Date
        let book: Book
    }
    
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        
        collectionView.dataSource = dataSource
    }
    
    func cellRegistrationHandler(cell: CalendarDetailCollectionViewCell, indexPath: IndexPath, item: Item) {
        cell.configure(with: (item.archivedAt, item.book))
    }
    
    func createSnapshot(_ items: [Item]) {
        let itemsWithDate = items.map { Item(archivedAt: $0.archivedAt, book: $0.book) }
        
        snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(itemsWithDate)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}

//MARK: - Reactive+
extension Reactive where Base: CalendarDetailViewController {
    
    fileprivate var createSnapshot: Binder<[CalendarDetailViewController.Item]> {
        return Binder(base) { base, value in
            base.createSnapshot(value)
        }
    }
}
