//
//  UIButton+Configuration.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import UIKit

extension UIButton.Configuration {
    
    static func accessory(title: String, image systemImageName: String? = nil) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .regular)
        
        configuration.attributedTitle = AttributedString(title, attributes: container)
        configuration.baseForegroundColor = TomeLinkColor.subtitle
        
        if let systemImageName {
            configuration.image = UIImage(systemName: systemImageName)
            configuration.imagePlacement = .trailing
            configuration.buttonSize = .mini
            configuration.imagePadding = 1.0
        }
        
        return configuration
    }
}
