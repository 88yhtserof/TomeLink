//
//  Reading.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/11/25.
//

import Foundation

struct Reading: Hashable {
    let isbn: String
    var currentPage: Int
    var pageCount: Int
    let startedAt: Date
    let book: Book

    var progress: Double {
        guard pageCount > 0 else { return 0 }
        return Double(currentPage) / Double(pageCount)
    }
}
