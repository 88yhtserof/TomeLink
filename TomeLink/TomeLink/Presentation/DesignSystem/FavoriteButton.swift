//
//  FavoriteButton.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import UIKit

import Toast
import RxSwift
import RxCocoa

final class FavoriteButton: UIButton {
    
    private var nomalConfiguration = UIButton.Configuration.plain()
    private var selectedConfiguration = UIButton.Configuration.plain()
    
    private var viewModel: FavoriteButtonViewModel?
    private var disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        
        configureView()
        
        configurationUpdateHandler = { [weak self] button in
            switch button.state {
            case .normal:
                button.configuration = self?.nomalConfiguration
            case .selected:
                button.configuration = self?.selectedConfiguration
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
    
    func bind(viewModel: FavoriteButtonViewModel) {
        
        self.viewModel = viewModel
        
        let input = FavoriteButtonViewModel.Input(isSelectedState: rx.isSelectedState,
                                                  selectButton: rx.tap)
        let output = viewModel.transform(input: input)
        
        output.selectedState
            .drive(rx.isSelected)
            .disposed(by: disposeBag)
        
        output.savingMessage
            .drive(with: self) { owner, value in
                let (message, id) = value
                NotificationCenter.default.post(name: NSNotification.Name("FavoriteButtonDidSave"), object: nil, userInfo: ["message": message])
                NotificationCenter.default.post(name: NSNotification.Name("FavoriteButtonResult"), object: nil, userInfo: ["id": id, "result": owner.isSelected])
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Configuration
private extension FavoriteButton {
    
    func configureView() {
        
        nomalConfiguration.image = UIImage(systemName: "heart")
        nomalConfiguration.baseForegroundColor = TomeLinkColor.shadow
        nomalConfiguration.baseBackgroundColor = .clear
        
        selectedConfiguration.image = UIImage(systemName: "heart.fill")
        selectedConfiguration.baseForegroundColor = TomeLinkColor.point
        selectedConfiguration.baseBackgroundColor = .clear
    }
}

extension Reactive where Base: FavoriteButton {
    var isSelectedState: ControlProperty<Bool> {
        return controlProperty(editingEvents: [.touchUpInside]) { button in
            return button.isSelected
        } setter: { button, value in
            button.isSelected = value
        }
    }
}
