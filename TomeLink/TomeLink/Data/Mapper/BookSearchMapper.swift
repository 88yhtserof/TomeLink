//
//  BookSearchMapper.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

extension BookSearchResponseDTO {
    func toDomain() -> BookSearch {
        return BookSearch(
            meta: meta.toDomain(),
            books: documents.map { $0.toDomain() }
        )
    }
}

extension MetaDTO {
    func toDomain() -> Meta {
        return Meta(
            isEnd: isEnd,
            pageableCount: pageableCount,
            totalCount: totalCount
        )
    }
}

extension BookDTO {
    func toDomain() -> Book {
        return Book(
            authors: authors,
            contents: contents,
            publicationDate: ISO8601DateFormatter().date(from: datetime),
            isbn: isbn,
            publisher: publisher,
            thumbnailURL: URL(string: thumbnail),
            title: title,
            translators: translators,
            detailURL: URL(string: url)
        )
    }
}

