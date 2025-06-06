//
//  ThumbnailView.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/3/25.
//

import UIKit

final class ThumbnailView: UIView {
    
    private let thumbnailImageView = UIImageView()
    
    var image: UIImage? {
        get { thumbnailImageView.image }
        set { thumbnailImageView.image = newValue }
    }
    
    init() {
        super.init(frame: .zero)
        
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(with urlString: String) {
        
        let imageURLString = ImageResizingManager.resizingImage(for: urlString)
        if let url = URL(string: imageURLString) {
            thumbnailImageView.kf.indicatorType = .activity
            thumbnailImageView.kf.setImage(with: url,
                                           placeholder: UIImage(named: "Image_placeholder"))
        }
    }
}

//MARK: - Configuration
private extension ThumbnailView {
    
    func configureView() {
        
        self.shadow()
        
        thumbnailImageView.backgroundColor = TomeLinkColor.imagePlaceholder
        thumbnailImageView.border(width: 0.5, color: TomeLinkColor.shadow)
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.image = UIImage(named: "Image_placeholder")
    }
    
    func configureHierarchy() {
        self.addSubview(thumbnailImageView)
    }
    
    func configureConstraints() {
        
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
