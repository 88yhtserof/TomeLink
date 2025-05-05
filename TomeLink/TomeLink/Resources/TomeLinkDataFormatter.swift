//
//  TomeLinkDataFormatter.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/10/25.
//

import Foundation

enum TomeLinkDataFormatter {
    
    static let startedAt: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd E"
        let languge = Locale.preferredLanguages.first ?? "ko_KR"
        dateFormatter.locale = Locale(identifier: languge)
        return dateFormatter
    }()
}
