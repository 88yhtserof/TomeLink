//
//  BookSearch.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

struct BookSearch {
    let meta: Meta
    let books: [Book]
}

struct Meta {
    let isEnd: Bool
    let pageableCount: Int
    let totalCount: Int
}

struct Book: Hashable {
    let authors: [String]
    let contents: String
    let publicationDate: Date?
    let isbn: String
    let price: Int
    let publisher: String
    let salePrice: Int
    let status: String
    let thumbnailURL: URL?
    let title: String
    let translators: [String]
    let detailURL: URL?
}
