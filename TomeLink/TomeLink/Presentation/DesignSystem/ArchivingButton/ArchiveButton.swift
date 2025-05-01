//
//  ArchiveButton.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/29/25.
//

import UIKit

final class ArchiveButton: UIButton {
    
    private var normalConfiguration = UIButton.Configuration.plain()
    
    init() {
        super.init(frame: .zero)
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Configuration
private extension ArchiveButton {
    
    func configureView() {
        
        normalConfiguration.image = UIImage(systemName: "calendar.badge.plus")
        normalConfiguration.baseForegroundColor = TomeLinkColor.title
        normalConfiguration.baseBackgroundColor = .clear
        
        self.configuration = normalConfiguration
    }
}
