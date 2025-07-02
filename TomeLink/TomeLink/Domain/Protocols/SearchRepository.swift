//
//  SearchRepository.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/2/25.
//

import Foundation

import RxSwift
import RxCocoa

protocol SearchRepository {
    
    func requestSearch(keyword: String, page: Int, isConnectedToNetwork: BehaviorRelay<Bool>, isLoading: PublishRelay<Bool>) -> Observable<BookSearch>
}
