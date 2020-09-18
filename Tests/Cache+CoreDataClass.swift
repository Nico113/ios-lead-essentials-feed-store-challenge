//
//  Cache+CoreDataClass.swift
//  FeedStoreChallenge
//
//  Created by Nicolas De Maio on 9/18/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData
import FeedStoreChallenge

@objc(Cache)
public class Cache: NSManagedObject {

    internal var local: [LocalFeedImage] {
        if let items = items {
            return (items.compactMap{ $0 as? FeedImage }).map { $0.local }
        }
        return [LocalFeedImage]()
    }
}
