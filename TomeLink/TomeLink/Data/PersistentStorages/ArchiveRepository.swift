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
    
    func updateArchive(at id: UUID, with value: Archive) {
        guard let archiveEntity = fetchArchiveEntity(for: id) else {
            print("Failed to update to archive")
            return
        }
        
        let book = value.book
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
        
        archiveEntity.archivedAt = value.archivedAt
        archiveEntity.book = bookEntity
        archiveEntity.isbn = value.book.isbn
        archiveEntity.note = value.note
        
        CoreDataStack.shared.save()
    }
    
    func fetchArchive(for id: UUID) -> Archive? {
        
        guard let archiveEntity = fetchArchiveEntity(for: id) else { return nil }
        
        let bookEntity =  archiveEntity.book
        let book = Book(authors: bookEntity.authors, contents: bookEntity.contents, publicationDate: bookEntity.publicationDate, isbn: bookEntity.isbn, publisher: bookEntity.publisher, thumbnailURL: bookEntity.thumbnailURL, title: bookEntity.title, translators: bookEntity.translators, detailURL: bookEntity.detailURL)
        
        return Archive(id: archiveEntity.id, archivedAt: archiveEntity.archivedAt, isbn: book.isbn, note: archiveEntity.note, book: book)
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
                
                return Archive(
                    id: entity.id,
                    archivedAt: entity.archivedAt,
                    isbn: entity.isbn,
                    note: entity.note,
                    book: book
                )
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

//MARK: - Entity
private extension ArchiveRepository {
    
    func fetchArchiveEntity(for id: UUID) -> ArchiveEntity? {
        let request: NSFetchRequest = ArchiveEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        return try? context.fetch(request).first
    }
}
