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
        
        let input = CalendarDetailViewModel.Input(viewWillAppear: rx.viewWillAppear)
        let output = viewMdoel.transform(input: input)
        
        output.bookWithDateList
            .map { list in
                list.map{ Item(archivedAt: $0.0, book: $0.1) }
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
        let spacing: CGFloat = 16
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing / 2.0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing / 2.0
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing / 2.0, leading: spacing, bottom: spacing / 2.0, trailing: spacing)
        
        return UICollectionViewCompositionalLayout(section: section)
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
