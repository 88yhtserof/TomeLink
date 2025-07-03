//
//  BookSearchResponseDTO.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

struct BookSearchResponseDTO: Decodable {
    let meta: MetaDTO
    let documents: [BookDTO]
}

struct MetaDTO: Decodable {
    let isEnd: Bool
    let pageableCount: Int
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isEnd = try container.decodeIfPresent(Bool.self, forKey: .isEnd) ?? true
        self.pageableCount = try container.decodeIfPresent(Int.self, forKey: .pageableCount) ?? 1
        self.totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? 1
    }
}

struct BookDTO: Decodable {
    let authors: [String]
    let contents: String
    let datetime: String
    let isbn: String
    let price: Int
    let publisher: String
    let salePrice: Int
    let status: String
    let thumbnail: String
    let title: String
    let translators: [String]
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case authors, contents, datetime, isbn, price, publisher
        case salePrice = "sale_price"
        case status, thumbnail, title, translators, url
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.authors = try container.decodeIfPresent([String].self, forKey: .authors) ?? []
        self.contents = try container.decodeIfPresent(String.self, forKey: .contents) ?? ""
        self.datetime = try container.decodeIfPresent(String.self, forKey: .datetime) ?? ""
        self.isbn = try container.decodeIfPresent(String.self, forKey: .isbn) ?? ""
        self.price = try container.decodeIfPresent(Int.self, forKey: .price) ?? 0
        self.publisher = try container.decodeIfPresent(String.self, forKey: .publisher) ?? ""
        self.salePrice = try container.decodeIfPresent(Int.self, forKey: .salePrice) ?? 0
        self.status = try container.decodeIfPresent(String.self, forKey: .status) ?? ""
        self.thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail) ?? ""
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.translators = try container.decodeIfPresent([String].self, forKey: .translators) ?? []
        self.url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
    }
}
