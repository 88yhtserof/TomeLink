//
//  BookEntity+CoreDataProperties.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/10/25.
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
    @NSManaged public var reading: NSSet

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

// MARK: Generated accessors for reading
extension BookEntity {

    @objc(addReadingObject:)
    @NSManaged public func addToReading(_ value: ReadingEntity)

    @objc(removeReadingObject:)
    @NSManaged public func removeFromReading(_ value: ReadingEntity)

    @objc(addReading:)
    @NSManaged public func addToReading(_ values: NSSet)

    @objc(removeReading:)
    @NSManaged public func removeFromReading(_ values: NSSet)

}

extension BookEntity : Identifiable {

}
