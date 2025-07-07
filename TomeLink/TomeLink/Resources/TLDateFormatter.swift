//
//  TLDateFormatter.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/10/25.
//

import Foundation

enum TLDateFormatter {
    case iso8601
    case startedAt
    case notifiedAt
    
    private static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    private static let startedAtFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd E"
        let languge = Locale.preferredLanguages.first ?? "ko_KR"
        dateFormatter.locale = Locale(identifier: languge)
        return dateFormatter
    }()
    
    private static let notifiedAtFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let languge = Locale.preferredLanguages.first ?? "ko_KR"
        dateFormatter.locale = Locale(identifier: languge)
        return dateFormatter
    }()
    
    var formatter: DateFormatter {
        switch self {
        case .iso8601:
            TLDateFormatter.iso8601Formatter
        case .startedAt:
            TLDateFormatter.startedAtFormatter
        case .notifiedAt:
            TLDateFormatter.notifiedAtFormatter
        }
    }
}

extension TLDateFormatter {
    
    func string(from date: Date) -> String {
        self.formatter.string(from: date)
    }
    
    func date(from string: String) -> Date? {
        self.formatter.date(from: string)
    }
}
