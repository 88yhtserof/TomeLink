//
//  ReadingEntity+CoreDataProperties.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/10/25.
//
//

import Foundation
import CoreData


extension ReadingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReadingEntity> {
        return NSFetchRequest<ReadingEntity>(entityName: "ReadingEntity")
    }

    @NSManaged public var startedAt: Date
    @NSManaged public var isbn: String
    @NSManaged public var book: BookEntity

}

extension ReadingEntity : Identifiable {

}
