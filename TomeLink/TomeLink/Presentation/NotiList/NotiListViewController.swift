//
//  NotiListViewController.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/1/25.
//

import UIKit

final class NotiListViewController: UIViewController {
    
    // view
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout())
    
    // property
    private var dataSource: DataSource!
    private let notiList: [Item] = [Item(item: "오만과 편견")]
    
    // life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureConstraints()
        configureView()
        configureDataSource()
    }
}

//MARK: - Configuration
private extension NotiListViewController {
    
    func configureView() {
        view.backgroundColor = TomeLinkColor.background
        
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
    }
    
    func configureHierarchy() {
        view.addSubviews(collectionView)
    }
    
    func configureConstraints() {
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

//MARK: - CollectionView Layout
private extension NotiListViewController {
    
    func listLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

//MARK: - CollectionView DataSource
private extension NotiListViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section {
        case notifications
    }
    
    typealias Item = IdentifiableItem<String>
    
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistraionHandler)
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        updateSnapshot()
        collectionView.dataSource = dataSource
    }
    
    func cellRegistraionHandler(cell: NotiListCollectionViewCell, indexPath: IndexPath, item: Item) {
        cell.configure(with: item.item)
    }
    
    func updateSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.notifications])
        snapshot.appendItems(notiList)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}
