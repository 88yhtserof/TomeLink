//
//  TomeLinkDataFormatter.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/10/25.
//

import Foundation

enum TomeLinkDataFormatter {
    
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static let startedAt: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd E"
        let languge = Locale.preferredLanguages.first ?? "ko_KR"
        dateFormatter.locale = Locale(identifier: languge)
        return dateFormatter
    }()
}
