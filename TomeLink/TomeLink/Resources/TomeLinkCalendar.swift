//
//  TomeLinkCalendar.swift
//  TomeLink
//
//  Created by 임윤휘 on 5/5/25.
//

import Foundation

enum TomeLinkCalendar {
    case calendar
    
    static let utcCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar
    }()
    
    
    static func isDate(_ date1: Date,
                       inSameDayAs date2: Date,
                       in calendar: TomeLinkCalendar) -> Bool {
        
        switch calendar {
        case .calendar:
            return utcCalendar.isDate(date1, inSameDayAs: date2)
        }
    }
    
    static func component(_ component: Calendar.Component,
                          from date: Date,
                          in calendar: TomeLinkCalendar) -> Int {
        switch calendar {
        case .calendar:
            return Calendar.current.component(component, from: date)
        }
    }
}
