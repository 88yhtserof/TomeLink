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
        
        Observable.just(value)
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(cellIdentifier: LibraryThumbnailCollectionViewCell.identifier, cellType: LibraryThumbnailCollectionViewCell.self)) { item, element, cell in
                cell.configure(with: element)
            }
            .disposed(by: disposeBag)
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
        
        let spacing: CGFloat = 16
        let width: CGFloat = (frame.width - spacing * 3 ) / 2.0
        let height: CGFloat = width * (4.5 / 3.0)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
