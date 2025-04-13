//
//  ObserveNetworkStatusUseCase.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/13/25.
//

import Foundation

import RxSwift

protocol ObserveNetworkStatusUseCase {
    var isConnected: Observable<Bool> { get }
    func start()
    func stop()
}

final class DefaultObserveNetworkStatusUseCase: ObserveNetworkStatusUseCase {
    private let monitor: NetworkMonitor

    init(monitor: NetworkMonitor) {
        self.monitor = monitor
    }

    var isConnected: Observable<Bool> {
        return monitor.isConnected
    }

    func start() {
        monitor.startMonitoring()
    }

    func stop() {
        monitor.stopMonitoring()
    }
}
