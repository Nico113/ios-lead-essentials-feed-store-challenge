//
//  Cache+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Nicolas De Maio on 9/18/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

extension Cache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cache> {
        return NSFetchRequest<Cache>(entityName: "Cache")
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var items: NSOrderedSet?

}

// MARK: Generated accessors for items
extension Cache {

    @objc(insertObject:inItemsAtIndex:)
    @NSManaged public func insertIntoItems(_ value: FeedImage, at idx: Int)

    @objc(removeObjectFromItemsAtIndex:)
    @NSManaged public func removeFromItems(at idx: Int)

    @objc(insertItems:atIndexes:)
    @NSManaged public func insertIntoItems(_ values: [FeedImage], at indexes: NSIndexSet)

    @objc(removeItemsAtIndexes:)
    @NSManaged public func removeFromItems(at indexes: NSIndexSet)

    @objc(replaceObjectInItemsAtIndex:withObject:)
    @NSManaged public func replaceItems(at idx: Int, with value: FeedImage)

    @objc(replaceItemsAtIndexes:withItems:)
    @NSManaged public func replaceItems(at indexes: NSIndexSet, with values: [FeedImage])

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: FeedImage)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: FeedImage)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSOrderedSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSOrderedSet)

}

extension Cache : Identifiable {

}
