//
//  CategoryButton.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/4/25.
//

import UIKit

final class CategoryButton: UIButton {
    
    private var normalConfiguration = UIButton.Configuration.plain()
    private var selectedConfiguration = UIButton.Configuration.filled()
    
    var title: String? {
        get { self.currentTitle }
        set {
            var attributedString = AttributedString(newValue ?? "")
            attributedString.font = TomeLinkFont.category
            normalConfiguration.attributedTitle = attributedString
            selectedConfiguration.attributedTitle = attributedString
            configuration?.attributedTitle = attributedString
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        configureView()
        
        configurationUpdateHandler = { [weak self] button in
            
            switch button.state {
            case .normal:
                self?.configuration = self?.normalConfiguration
            case .selected:
                self?.configuration = self?.selectedConfiguration
            default:
                break
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        isSelected.toggle()
    }
}

//MARK: - Configuration
private extension CategoryButton {
    
    func configureView() {
        
        cornerRadius(4)
        border()
        
        normalConfiguration.baseForegroundColor = TomeLinkColor.title
        normalConfiguration.baseBackgroundColor = TomeLinkColor.point
        
        selectedConfiguration.baseForegroundColor = TomeLinkColor.imagePlaceholder
        selectedConfiguration.baseBackgroundColor = TomeLinkColor.title
    }
}
