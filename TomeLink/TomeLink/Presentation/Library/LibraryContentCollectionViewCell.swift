//
//  LibraryContentCollectionViewCell.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/2/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class LibraryContentCollectionViewCell: UICollectionViewCell, BaseCollectionViewCell {
    
    static let identifier = String(describing: LibraryContentCollectionViewCell.self)
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        collectionView.dataSource = nil
        disposeBag = DisposeBag()
        
    }
    
    func configure(with value: [String]) {
        //        Observable.just(value)
        //            .asDriver(onErrorJustReturn: [])
        //            .drive(collectionView.rx.items(cellIdentifier: CoinListCollectionViewCell.identifier, cellType: CoinListCollectionViewCell.self)) { item, element, cell in
        //                cell.configure(with: element)
        //            }
        //            .disposed(by: disposeBag)
    }
}

//MARK: - Configuration
private extension LibraryContentCollectionViewCell {
    
    func configureView() {
        
        collectionView.backgroundColor = .clear
        collectionView.register(LibraryThumbnailCollectionViewCell.self, forCellWithReuseIdentifier: LibraryThumbnailCollectionViewCell.identifier)
    }
    
    func configureHierarchy() {
        contentView.addSubviews(collectionView)
    }
    
    func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(60)
        }
    }
}

//MARK: - CollectionView Layout
private extension LibraryContentCollectionViewCell {
    
    func layout() -> UICollectionViewCompositionalLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(180))
        let internalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let externalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let internalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: internalGroupSize, subitems: [item])
        let externalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: externalGroupSize, subitems: [internalGroup, internalGroup])
        
        let section = NSCollectionLayoutSection(group: externalGroup)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
