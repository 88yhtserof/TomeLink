//
//  ArchiveRepository.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/19/25.
//

import Foundation
import CoreData

struct ArchiveRepository: ArchiveRepositoryProtocol {
    
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    
    func addArchive(book: Book, note: String?, archivedAt date: Date) {
        
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
        
        let archive = ArchiveEntity(context: context)
        archive.id = UUID()
        archive.archivedAt = date
        archive.book = bookEntity
        archive.isbn = book.isbn
        archive.note = note
        
        CoreDataStack.shared.save()
    }
    
    func updateArchive(at id: UUID, with value: Archive) throws {
        
        guard var archive = fetchArchive(for: id) else {
            throw RepositoryError.failedToFetchData
        }
        archive.archivedAt = value.archivedAt
        archive.book = value.book
        archive.isbn = value.book.isbn
        archive.note = value.note
        
        CoreDataStack.shared.save()
    }
    
    func fetchArchive(for id: UUID) -> Archive? {
        
        guard let archiveEntity = fetchArchiveEntity(for: id) else { return nil }
        
        let bookEntity =  archiveEntity.book
        let book = Book(authors: bookEntity.authors, contents: bookEntity.contents, publicationDate: bookEntity.publicationDate, isbn: bookEntity.isbn, publisher: bookEntity.publisher, thumbnailURL: bookEntity.thumbnailURL, title: bookEntity.title, translators: bookEntity.translators, detailURL: bookEntity.detailURL)
        
        return Archive(archivedAt: archiveEntity.archivedAt, isbn: book.isbn, book: book)
    }
    
    func fetchAllArchives() -> [Archive] {
        let request: NSFetchRequest = ArchiveEntity.fetchRequest()
        guard let archiveEntities = try? context.fetch(request) else {
            return []
        }
        
        return archiveEntities
            .map { entity in
                let bookEntity = entity.book
                let book = Book(authors: bookEntity.authors, contents: bookEntity.contents, publicationDate: bookEntity.publicationDate, isbn: bookEntity.isbn, publisher: bookEntity.publisher, thumbnailURL: bookEntity.thumbnailURL, title: bookEntity.title, translators: bookEntity.translators, detailURL: bookEntity.detailURL)
                
                return Archive(archivedAt: entity.archivedAt, isbn: entity.isbn, book: book)
            }
    }
    
    func deleteArchive(at id: UUID) {
        
        guard let archiveEntity = fetchArchiveEntity(for: id) else {
            return
        }
        context.delete(archiveEntity)
        CoreDataStack.shared.save()
    }
}

private extension ArchiveRepository {
    
    func fetchArchiveEntity(for id: UUID) -> ArchiveEntity? {
        let request: NSFetchRequest = ArchiveEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        return try? context.fetch(request).first
    }
}
