//
//  NotificationTopicSubscribeManager.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/4/25.
//

import Foundation

struct NotificationTopicsSubscribeManager: NotificationTopicsSubscribe {
    
    @UserDefaultsWrapper(key: "all_topic_subscriptions", defaultValue: false)
    static var allTopicSubscriptions: Bool
    
    @UserDefaultsWrapper(key: "recommend_topic_subscriptions", defaultValue: false)
    static var recommendTopicSubscriptions: Bool
    
    var isAllTopicSubscribed: Bool {
        return NotificationTopicsSubscribeManager.allTopicSubscriptions
    }
    
    var isRecommendTopicSubscribed: Bool {
        return NotificationTopicsSubscribeManager.recommendTopicSubscriptions
    }
    
    func subscribeAllTopics() {
        NotificationTopicsSubscribeManager.allTopicSubscriptions = true
    }
    
    func unsubscribeAllTopics() {
        NotificationTopicsSubscribeManager.allTopicSubscriptions = false
    }
    
    func subscribeRecommendTopics() {
        NotificationTopicsSubscribeManager.recommendTopicSubscriptions = true
    }
    
    func unsubscribeRecommendTopics() {
        NotificationTopicsSubscribeManager.recommendTopicSubscriptions = false
    }
}
