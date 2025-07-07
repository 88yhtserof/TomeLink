//
//  NotificationTopicSubscribe.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/4/25.
//

import Foundation

protocol NotificationTopicsSubscribe {
    
    var isAllTopicSubscribed: Bool { get }
    var isRecommendTopicSubscribed: Bool { get }
    
    func subscribeAllTopics()

    func unsubscribeAllTopics()
    
    func subscribeRecommendTopics()
    
    func unsubscribeRecommendTopics()
}
