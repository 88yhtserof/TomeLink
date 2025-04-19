//
//  ArchiveEntity+CoreDataProperties.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/18/25.
//
//

import Foundation
import CoreData


extension ArchiveEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArchiveEntity> {
        return NSFetchRequest<ArchiveEntity>(entityName: "ArchiveEntity")
    }

    @NSManaged public var isbn: String
    @NSManaged public var archivedAt: Date
    @NSManaged public var note: String?
    @NSManaged public var id: UUID
    @NSManaged public var book: BookEntity

}

extension ArchiveEntity : Identifiable {

}
