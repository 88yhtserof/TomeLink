//
//  Archive.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/19/25.
//

import Foundation

struct Archive: Identifiable {
    var id = UUID()
    var archivedAt: Date
    var isbn: String
    var note: String?
    var book: Book
}

