//
//  LiveNotificationRepository.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/4/25.
//

import Foundation
import CoreData

struct LiveNotificationRepository: NotificationRepository {
    
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    
    func fetchAll() -> [NotificationItem] {
        return fetchAll().map{ $0.toDomain() }
    }
    
    func save(_ item: NotificationItem) {
        
        let entity = NotificationEntity(context: context)
        entity.id = item.id
        entity.isbn = item.isbn
        entity.notifiedAt = item.notifiedAt
        entity.title = item.title
        entity.content = item.content
        entity.type = item.type
        
        CoreDataStack.shared.save()
    }
}

//MARK: - Entity method
private extension LiveNotificationRepository {
    
    func fetchAll() -> [NotificationEntity] {
        let request: NSFetchRequest<NotificationEntity> = NotificationEntity.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \NotificationEntity.notifiedAt, ascending: false)]
        
        if !LastNotificationCleanUpDate.hasCleanedUpToday {
            do {
                try deleteOldNotifications()
            } catch {
                print("Failed to delete old notifications: \(error)")
            }
        }
        
        do {
            return try context.fetch(request)
            
        } catch {
            print("Fetching notifications failed: \(error)")
            return []
        }
    }
    
    func deleteOldNotifications() throws {
        let request: NSFetchRequest<NotificationEntity> = NotificationEntity.fetchRequest()
        
        if !LastNotificationCleanUpDate.hasCleanedUpToday {
            
            let calendar = Calendar.current
            guard let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: Date()) else {
                throw NotificationError.failedToDelete
            }
            
            request.predicate = NSPredicate(format: "notifiedAt < %@", tenDaysAgo as NSDate)
        }
        
        do {
            let oldNotifications = try context.fetch(request)
            
            for notification in oldNotifications {
                context.delete(notification)
            }
            
            CoreDataStack.shared.save()
            LastNotificationCleanUpDate.update()
            print("Successfully deleted old notifications")
            
        } catch {
            throw NotificationError.failedToDelete
        }
    }
}
