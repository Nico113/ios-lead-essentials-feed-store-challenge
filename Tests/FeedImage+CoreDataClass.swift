//
//  FeedImage+CoreDataClass.swift
//  FeedStoreChallenge
//
//  Created by Nicolas De Maio on 9/15/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData
import FeedStoreChallenge

@objc(FeedImage)
public class FeedImage: NSManagedObject {

    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
