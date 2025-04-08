//
//  FavoriteRepository.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/8/25.
//

import Foundation
import CoreData

struct FavoriteRepository {
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    
    func like(book: BookEntity) {
        let favorite = FavoriteEntity(context: context)
        favorite.id = UUID()
        favorite.createdAt = Date()
        favorite.book = book

        CoreDataStack.shared.save()
    }
    
    func isBookLiked(_ bookID: String) -> Bool {
        let request: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "book.id == %@", bookID)
        
        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }
}
