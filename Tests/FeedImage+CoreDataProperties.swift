//
//  FeedImage+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Nicolas De Maio on 9/15/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension FeedImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedImage> {
        return NSFetchRequest<FeedImage>(entityName: "FeedImage")
    }

    @NSManaged public var id: UUID
    @NSManaged public var imageDescription: String?
    @NSManaged public var location: String?
    @NSManaged public var url: URL

}
