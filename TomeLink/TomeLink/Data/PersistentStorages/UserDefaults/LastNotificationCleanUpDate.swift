//
//  LastNotificationCleanUpDate.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/4/25.
//

import Foundation

struct LastNotificationCleanUpDate {
    
    @UserDefaultsWrapper(key: "lastNotificationCleanupDate", defaultValue: Date())
    static var lastNotificationCleanupDate: Date
    
    static var hasCleanedUpToday: Bool {
        let  lastDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: lastNotificationCleanupDate)
        let todayDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return lastDateComponents.year == todayDateComponents.year &&
        lastDateComponents.month == todayDateComponents.month && lastDateComponents.day == todayDateComponents.day
    }
    
    static func update() {
        lastNotificationCleanupDate = Date()
    }
}
