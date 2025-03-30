//
//  NetworkRequesting.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/30/25.
//

import Foundation

import RxSwift
import RxCocoa

protocol NetworkRequesting {
    
    /**
     @param     api An API object to configure HTTP request, such as KakaoNetworkAPI
     */
    func requesting<T: Decodable>(api: NetworkAPI) -> Single<T>
}
