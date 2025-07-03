//
//  NotificationUseCase.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/1/25.
//

import Foundation

import FirebaseMessaging

struct NotificationUseCase {
    let topic: NotiTopic
    
    func subscribe() {
        Messaging.messaging().subscribe(toTopic: topic.name) { error in
            if let error = error {
                print("Error subscribing to topic: \(error)")
            } else {
                print("Subscribed to /topics/all")
            }
        }
    }
    
    func unsubscribe() {
        Messaging.messaging().unsubscribe(fromTopic: topic.name)
    }
}

extension NotificationUseCase {
    
    enum NotiTopic: String {
        case all
        case recommend
        
        var name: String {
            rawValue
        }
        
        var imageName: String {
            switch self {
            case .all:
                return "bell.circle"
            case .recommend:
                return "book.closed.circle"
            }
        }
    }
}
