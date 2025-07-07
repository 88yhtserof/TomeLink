//
//  NotificationUseCase.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/1/25.
//

import Foundation

import FirebaseMessaging

struct NotificationUseCase {
    
    private let notificationRepository: NotificationRepository
    private let notificationTopicsSubscribe: NotificationTopicsSubscribe
    
    init(notificationRepository: NotificationRepository, notificationTopicsSubscribe: NotificationTopicsSubscribe) {
        self.notificationRepository = notificationRepository
        self.notificationTopicsSubscribe = notificationTopicsSubscribe
    }
    
    func isSubscribed(to topic: NotiTopic) -> Bool {
        switch topic {
        case .all:
            return notificationTopicsSubscribe.isAllTopicSubscribed
        case .recommend:
            return notificationTopicsSubscribe.isRecommendTopicSubscribed
        }
    }
    
    func subscribe(to topic: NotiTopic) {
        Messaging.messaging().subscribe(toTopic: topic.name) { error in
            
            if let error = error {
                print("Error subscribing to topic: \(topic.name), \(error)")
            } else {
                print("Subscribed to \(topic.name)")
                
                switch topic {
                case .all:
                    notificationTopicsSubscribe.subscribeAllTopics()
                case .recommend:
                    notificationTopicsSubscribe.subscribeRecommendTopics()
                }
            }
        }
    }
    
    func unsubscribe(from topic: NotiTopic) {
        Messaging.messaging().unsubscribe(fromTopic: topic.name)
        print("Unsubscribed from \(topic.name)")
        
        switch topic {
        case .all:
            notificationTopicsSubscribe.unsubscribeAllTopics()
        case .recommend:
            notificationTopicsSubscribe.unsubscribeRecommendTopics()
        }
    }
    
    func fetchNotifications() -> [NotificationItem] {
        notificationRepository.fetchAll()
    }
    
    func saveNotification(isbn: String, title: String, content: String, type: String) {
        let item = NotificationItem(id: UUID(), isbn: isbn, notifiedAt: Date(), title: title, content: content, type: type)
        notificationRepository.save(item)
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
