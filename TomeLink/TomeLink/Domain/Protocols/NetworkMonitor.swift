//
//  NetworkMonitor.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

import RxSwift
import RxCocoa

protocol NetworkMonitor {
    
    var isConnected: Observable<Bool> { get }
    
    func startMonitoring()
    func stopMonitoring()
}
