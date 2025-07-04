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

    func toDomain() -> Notification {
        return Notification(
            id: self.id,
            isbn: self.isbn,
            notifiedAt: self.notifiedAt,
            title: self.title,
            type: self.type
        )
    }
}
