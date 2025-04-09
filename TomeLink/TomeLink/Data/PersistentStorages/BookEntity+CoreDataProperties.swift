//
//  BookEntity+CoreDataProperties.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/8/25.
//
//

import Foundation
import CoreData


extension BookEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookEntity> {
        return NSFetchRequest<BookEntity>(entityName: "BookEntity")
    }

    @NSManaged public var authors: [String]
    @NSManaged public var contents: String
    @NSManaged public var detailURL: String
    @NSManaged public var isbn: String
    @NSManaged public var publicationDate: Date
    @NSManaged public var publisher: String
    @NSManaged public var thumbnailURL: String
    @NSManaged public var title: String
    @NSManaged public var translators: [String]
    @NSManaged public var favorite: NSSet

}

// MARK: Generated accessors for favorite
extension BookEntity {

    @objc(addFavoriteObject:)
    @NSManaged public func addToFavorite(_ value: FavoriteEntity)

    @objc(removeFavoriteObject:)
    @NSManaged public func removeFromFavorite(_ value: FavoriteEntity)

    @objc(addFavorite:)
    @NSManaged public func addToFavorite(_ values: NSSet)

    @objc(removeFavorite:)
    @NSManaged public func removeFromFavorite(_ values: NSSet)

}

extension BookEntity : Identifiable {

}
