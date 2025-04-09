//
//  FavoriteRepository.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/8/25.
//

import Foundation
import CoreData

struct FavoriteRepository: FavoriteRepositoryProtocol {
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    
    func like(book: Book) {
        
        let bookEntity = BookEntity(context: context)
        bookEntity.authors = book.authors
        bookEntity.contents = book.contents
        bookEntity.detailURL = book.detailURL?.absoluteString ?? ""
        bookEntity.isbn = book.isbn
        bookEntity.publicationDate = book.publicationDate ?? Date()
        bookEntity.publisher = book.publisher
        bookEntity.thumbnailURL = book.thumbnailURL?.absoluteString ?? ""
        bookEntity.title = book.title
        bookEntity.translators = book.translators
        
        let favorite = FavoriteEntity(context: context)
        favorite.isbn = book.isbn
        favorite.createdAt = Date()
        favorite.book = bookEntity

        CoreDataStack.shared.save()
    }
    
    func unlike(isbn: String) {
        let request: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isbn == %@", isbn)

        if let favorites = try? context.fetch(request) {
            for favorite in favorites {
                context.delete(favorite)
            }
            CoreDataStack.shared.save()
        }
    }
    
    func isBookLiked(for isbn: String) -> Bool {
        let request: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isbn == %@", isbn)
        
        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }
    
    func fetchFavorites() -> [Book] {
        let request: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let favorites = try? context.fetch(request)
        
        return favorites?
            .map{ $0.book }
            .map {
                return Book(authors: $0.authors, contents: $0.contents, publicationDate: $0.publicationDate, isbn: $0.isbn, publisher: $0.publisher, thumbnailURL: URL(string: $0.thumbnailURL), title: $0.title, translators: $0.translators, detailURL: URL(string: $0.detailURL))
            } ?? []
    }
}
