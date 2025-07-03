//
//  NotificationEntity+CoreDataProperties.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/3/25.
//
//

import Foundation
import CoreData


extension NotificationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationEntity> {
        return NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
    }

    @NSManaged public var type: String
    @NSManaged public var title: String
    @NSManaged public var isbn: String
    @NSManaged public var notifiedAt: Date
    @NSManaged public var id: UUID

}

extension NotificationEntity : Identifiable {

}
