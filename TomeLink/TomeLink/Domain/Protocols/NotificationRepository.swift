//
//  NotificationRepository.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/4/25.
//

import Foundation

protocol NotificationRepository {
    
    func fetchAll() -> [Notification]
}
