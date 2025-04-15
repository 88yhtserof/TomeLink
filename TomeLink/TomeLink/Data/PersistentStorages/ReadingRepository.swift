//
//  ReadingRepository.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/11/25.
//

import Foundation
import CoreData

struct ReadingRepository: ReadingRepositoryProtocol {
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    
    func isBookReading(isbn: String) -> Bool {
        let request: NSFetchRequest<ReadingEntity> = ReadingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isbn == %@", isbn)
        request.fetchLimit = 1
        
        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }
    
    func addReading(book: Book, currentPage: Int32, pageCount: Int32, startedAt: Date) {
        
        let bookEntity = BookEntity(context: context)
        bookEntity.authors = book.authors
        bookEntity.contents = book.contents
        bookEntity.detailURL = book.detailURL
        bookEntity.isbn = book.isbn
        bookEntity.publicationDate = book.publicationDate ?? Date()
        bookEntity.publisher = book.publisher
        bookEntity.thumbnailURL = book.thumbnailURL
        bookEntity.title = book.title
        bookEntity.translators = book.translators
        
        let reading = ReadingEntity(context: context)
        reading.startedAt = startedAt
        reading.isbn = book.isbn
        reading.pageCount = Int32(pageCount)
        reading.currentPage = Int32(currentPage)
        reading.book = bookEntity

        CoreDataStack.shared.save()
    }

    func updateCurrentPage(isbn: String, currentPage: Int32) {
        guard let reading = fetchReading(isbn: isbn) else { return }
        reading.currentPage = currentPage
        CoreDataStack.shared.save()
    }

    func fetchReading(isbn: String) -> ReadingEntity? {
        let request: NSFetchRequest<ReadingEntity> = ReadingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isbn == %@", isbn)
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    func deleteReading(isbn: String) {
        if let reading = fetchReading(isbn: isbn) {
            context.delete(reading)
            CoreDataStack.shared.save()
        }
    }

    func fetchAllReadings() -> [Reading] {
        let request: NSFetchRequest<ReadingEntity> = ReadingEntity.fetchRequest()
        let readings = try? context.fetch(request)
        
        return readings?
            .map {
                let bookEntity = $0.book
                let book = Book(authors: bookEntity.authors, contents: bookEntity.contents, publicationDate: bookEntity.publicationDate, isbn: bookEntity.isbn, publisher: bookEntity.publisher, thumbnailURL: bookEntity.thumbnailURL, title: bookEntity.title, translators: bookEntity.translators, detailURL: bookEntity.detailURL)
                
                return Reading(isbn: book.isbn, currentPage: Int($0.currentPage), pageCount: Int($0.pageCount), startedAt: $0.startedAt, book: book)
            } ?? []
    }
}
