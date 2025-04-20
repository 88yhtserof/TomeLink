//
//  Archive.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/19/25.
//

import Foundation

struct Archive: Identifiable, Hashable {
    var id = UUID()
    var archivedAt: Date
    var isbn: String
    var note: String?
    var book: Book
}

extension Archive {

    static let archives: [Archive] = [
        Archive(
            id: UUID(),
            archivedAt: Date(timeIntervalSinceNow: -86400 * 7), // 7일 전
            isbn: "978-3-16-148410-0",
            note: "Really enjoyed the storytelling and character development!",
            book: Book(
                authors: ["John Doe"],
                contents: "A thrilling novel about adventure and discovery...",
                publicationDate: Calendar.current.date(from: DateComponents(year: 2020, month: 5, day: 15)),
                isbn: "978-3-16-148410-0",
                publisher: "Adventure Press",
                thumbnailURL: "https://example.com/book1.jpg",
                title: "The Great Journey",
                translators: [],
                detailURL: "https://example.com/book1/details"
            )
        ),
        Archive(
            id: UUID(),
            archivedAt: Date(timeIntervalSinceNow: -86400 * 3), // 3일 전
            isbn: "978-1-23-456789-7",
            note: nil,
            book: Book(
                authors: ["Jane Smith", "Alan Brown"],
                contents: "A comprehensive guide to machine learning concepts...",
                publicationDate: Calendar.current.date(from: DateComponents(year: 2023, month: 8, day: 10)),
                isbn: "978-1-23-456789-7",
                publisher: "Tech Books",
                thumbnailURL: "https://example.com/book2.jpg",
                title: "Machine Learning Basics",
                translators: ["Kim Lee"],
                detailURL: "https://example.com/book2/details"
            )
        ),
        Archive(
            id: UUID(),
            archivedAt: Date(), // 오늘
            isbn: "978-0-12-345678-9",
            note: "A bit dense but very informative.",
            book: Book(
                authors: ["Emily White"],
                contents: "An exploration of historical events that shaped the modern world...",
                publicationDate: Calendar.current.date(from: DateComponents(year: 2018, month: 11, day: 22)),
                isbn: "978-0-12-345678-9",
                publisher: "History Hub",
                thumbnailURL: "https://example.com/book3.jpg",
                title: "History Unveiled",
                translators: [],
                detailURL: "https://example.com/book3/details"
            )
        )
    ]
}
