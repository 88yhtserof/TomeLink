//
//  ReadingReository.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/10/25.
//

import Foundation
import CoreData

final class ReadingRepository {
    private let context = CoreDataStack.shared.persistentContainer.viewContext

    // MARK: - Create
    func addReading(for book: BookEntity, startedAt: Date) {
        let reading = ReadingEntity(context: context)
        reading.startedAt = startedAt
        reading.book = book

        CoreDataStack.shared.save()
    }

    // MARK: - Read
    func fetchAll() -> [ReadingEntity] {
        let request: NSFetchRequest<ReadingEntity> = ReadingEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startedDate", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ ReadingEntity fetch 실패: \(error)")
            return []
        }
    }

    // MARK: - Update
    func updateReading(_ reading: ReadingEntity, startedAt: Date) {
        reading.startedAt = startedAt
        CoreDataStack.shared.save()
    }

    // MARK: - Delete
    func deleteReading(_ reading: ReadingEntity) {
        context.delete(reading)
        
        CoreDataStack.shared.save()
    }
}
