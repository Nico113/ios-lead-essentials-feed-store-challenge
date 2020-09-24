//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Nicolas De Maio on 9/20/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer?
    private let context: NSManagedObjectContext?
    
    public init(model: String = "FeedStore", bundle: Bundle = Bundle(for: CoreDataFeedStore.self)) throws {
        guard let mom = NSManagedObjectModel.mergedModel(from: [bundle]) else {
            container = nil
            context = nil
            return
        }
        
        container = NSPersistentContainer(name: model, managedObjectModel: mom)
        var receivedError: Error?
        container?.loadPersistentStores(completionHandler: { (storeDescription, error) in
            receivedError = error
        })
        if let error = receivedError {
            throw error
        }
        context = container?.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        if let context = context {
            context.perform {
                do {
                    if let currentCache: Cache = try context.fetch(Cache.fetchRequest()).first {
                        context.delete(currentCache)
                        do {
                            try context.save()
                            completion(.none)
                        } catch {
                            completion(error)
                        }
                    } else {
                        completion(.none)
                    }
                } catch {
                    completion(error)
                }
            }
        } else {
            completion(.none)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        if let context = context {
            context.perform {
                do {
                    if let cache: Cache = try context.fetch(Cache.fetchRequest()).first {
                        var feedImages = [NSManagedObject]()
                        for localFeedImage in feed {
                            let feedImage = FeedImage(context: context)
                            
                            feedImage.id = localFeedImage.id
                            feedImage.imageDescription = localFeedImage.description
                            feedImage.location = localFeedImage.location
                            feedImage.url = localFeedImage.url
                            
                            feedImages.append(feedImage)
                        }
                        
                        cache.timestamp = timestamp
                        cache.setValue(NSOrderedSet(array: feedImages), forKey: "items")
                        
                        try context.save()
                        completion(.none)
                    } else {
                        let cache = Cache(context: context)
                        
                        var feedImages = [NSManagedObject]()
                        for localFeedImage in feed {
                            let feedImage = FeedImage(context: context)
                            
                            feedImage.id = localFeedImage.id
                            feedImage.imageDescription = localFeedImage.description
                            feedImage.location = localFeedImage.location
                            feedImage.url = localFeedImage.url
                            
                            feedImages.append(feedImage)
                        }
                        
                        cache.timestamp = timestamp
                        cache.items = NSOrderedSet(array: feedImages)
                        
                        try context.save()
                        completion(.none)
                    }
                } catch {
                    completion(error)
                }
            }
        } else {
            completion(NSError())
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        if let context = context {
            context.perform {
                do {
                    if let cache: Cache = try context.fetch(Cache.fetchRequest()).first {
                        completion(.found(feed: cache.local, timestamp: cache.timestamp))
                    } else {
                        completion(.empty)
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        } else {
            completion(.empty)
        }
    }
}
