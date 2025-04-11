//
//  OutputEventEmittable.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/11/25.
//

import Foundation

import RxSwift
import RxCocoa

protocol OutputEventEmittable {
    
    var outputEvent: PublishRelay<OutputEvent> { get }
}

enum OutputEvent {
    case reloadTrigger
}

