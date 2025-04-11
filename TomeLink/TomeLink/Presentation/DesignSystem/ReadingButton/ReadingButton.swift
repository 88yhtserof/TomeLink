//
//  ReadingButton.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/10/25.
//

import UIKit

import RxSwift
import RxCocoa

final class ReadingButton: UIButton {
    
    enum State {
        case play
        case stop
        
        var imageName: String {
            switch self {
            case .play:
                return "play.fill"
            case .stop:
                return "stop.fill"
            }
        }
        
        var message: String {
            switch self {
            case .play:
                return "독서를 중단합니다."
            case .stop:
                return "독서를 시작합니다."
            }
        }
    }
    
    private var stopConfiguration = UIButton.Configuration.plain()
    private var playConfiguration = UIButton.Configuration.plain()
    
    private var viewModel: ReadingButtonViewModel?
    private var disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        
        configureView()
        
        configurationUpdateHandler = { [weak self] button in
            switch button.state {
            case .normal:
                button.configuration = self?.playConfiguration
            case .selected:
                button.configuration = self?.stopConfiguration
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
    
    func bind(viewModel: ReadingButtonViewModel) {
        
        self.viewModel = viewModel
        
        let input = ReadingButtonViewModel.Input(isSelectedState: rx.isPlayed,
                                                  selectButton: rx.tap)
        let output = viewModel.transform(input: input)
        
        output.selectedState
            .map({
                print("22222222", $0)
                return $0
            })
            .drive(rx.isSelected)
            .disposed(by: disposeBag)
        
        output.savingMessage
            .drive(with: self) { owner, value in
                let (message, id) = value
                NotificationCenter.default.post(name: NSNotification.Name("ReadingButtonDidSave"), object: nil, userInfo: ["message": message])
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Configuration
private extension ReadingButton {
    
    func configureView() {
        
        stopConfiguration.image = UIImage(systemName: State.play.imageName)
        stopConfiguration.baseForegroundColor = TomeLinkColor.title
        stopConfiguration.baseBackgroundColor = .clear
        
        playConfiguration.image = UIImage(systemName: State.stop.imageName)
        playConfiguration.baseForegroundColor = TomeLinkColor.title
        playConfiguration.baseBackgroundColor = .clear
    }
}

extension Reactive where Base: ReadingButton {
    var isPlayed: ControlProperty<Bool> {
        return controlProperty(editingEvents: [.touchUpInside]) { button in
            return button.isSelected
        } setter: { button, value in
            button.isSelected = value
        }
    }
}
