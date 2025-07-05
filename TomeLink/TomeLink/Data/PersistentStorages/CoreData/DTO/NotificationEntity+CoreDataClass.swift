//
//  NotificationEntity+CoreDataClass.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/3/25.
//
//

import Foundation
import CoreData

@objc(NotificationEntity)
public class NotificationEntity: NSManagedObject {

    func toDomain() -> NotificationItem {
        return NotificationItem(
            id: self.id,
            isbn: self.isbn,
            notifiedAt: self.notifiedAt,
            title: self.title,
            content: self.content,
            type: self.type
        )
    }
}
