//
//  ArchiveEditViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/29/25.
//

import Foundation

import RxSwift
import RxCocoa

final class ArchiveEditViewModel: BaseViewModel {
        
    let disposeBag = DisposeBag()
    
    struct Input {
    }
    
    struct Output {
        
    }
    
    private let isbn: String
    private let book: Book
    private let repository: ArchiveRepository
    
    
    init(book: Book, repository: ArchiveRepository) {
        self.book = book
        self.isbn = book.isbn
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        
        
        return Output()
    }
}

//MARK: - Action
extension ArchiveEditViewModel {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        
    }
}
