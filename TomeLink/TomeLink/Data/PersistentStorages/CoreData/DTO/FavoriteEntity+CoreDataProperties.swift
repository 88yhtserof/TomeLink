//
//  FavoriteEntity+CoreDataProperties.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/10/25.
//
//

import Foundation
import CoreData


extension FavoriteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteEntity> {
        return NSFetchRequest<FavoriteEntity>(entityName: "FavoriteEntity")
    }

    @NSManaged public var createdAt: Date
    @NSManaged public var isbn: String
    @NSManaged public var book: BookEntity

}

extension FavoriteEntity : Identifiable {

}
