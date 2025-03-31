//
//  BaseViewModel.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

import RxSwift

protocol BaseViewModel {
    
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get }
    
    func transform(input: Input) -> Output
}
