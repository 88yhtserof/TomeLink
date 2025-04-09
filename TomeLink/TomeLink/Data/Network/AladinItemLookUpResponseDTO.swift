//
//  AladinItemLookUpResponseDTO.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/9/25.
//

import Foundation

struct AladinItemLookUpResponseDTO: Codable {
    let title: String
    let link: String
    let item: AladinItem?

    enum CodingKeys: CodingKey {
        case title
        case link
        case item
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.link = try container.decodeIfPresent(String.self, forKey: .link) ?? ""
        self.item = try container.decodeIfPresent(AladinItem.self, forKey: .item)
    }
}

struct AladinItem: Codable {
    let bookinfo: BookInfo?
    
    enum CodingKeys: CodingKey {
        case bookinfo
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bookinfo = try container.decodeIfPresent(BookInfo.self, forKey: .bookinfo)
    }
}

struct BookInfo: Codable {
    let itemPage: Int
    
    enum CodingKeys: CodingKey {
        case itemPage
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.itemPage = try container.decodeIfPresent(Int.self, forKey: .itemPage) ?? 0
    }
}

