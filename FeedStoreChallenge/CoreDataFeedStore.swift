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
    private let modelName: String
    private let bundle: Bundle
    
    public init(model: String = "FeedStore", bundle: Bundle = Bundle(for: CoreDataFeedStore.self)) {
        modelName = model
        self.bundle = bundle
    }
    
    lazy var persistentContainer: NSPersistentContainer? = {
        if let mom = NSManagedObjectModel.mergedModel(from: [bundle]) {
            let container = NSPersistentContainer(name: modelName, managedObjectModel: mom)
                    
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            
            return container
        }
        return nil
    }()
    
    func deleteCurrentCache() throws {
        if let container = persistentContainer, let currentCache: Cache = try container.viewContext.fetch(Cache.fetchRequest()).first {
            container.viewContext.delete(currentCache)
            try container.viewContext.save()
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        do {
            try deleteCurrentCache()
            completion(.none)
        } catch {
            completion(error)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        if let container = persistentContainer, let feedImageEntity = NSEntityDescription.entity(forEntityName: "FeedImage", in: container.viewContext) {
            do {
                try deleteCurrentCache()
                
                let cache = Cache(context: container.viewContext)
                
                var feedImages = [NSManagedObject]()
                for localFeedImage in feed {
                    let feedImage = NSManagedObject(entity: feedImageEntity, insertInto: container.viewContext)
                    
                    feedImage.setValue(localFeedImage.id, forKey: "id")
                    feedImage.setValue(localFeedImage.description, forKey: "imageDescription")
                    feedImage.setValue(localFeedImage.location, forKey: "location")
                    feedImage.setValue(localFeedImage.url, forKey: "url")
                    
                    feedImages.append(feedImage)
                }
                
                cache.timestamp = timestamp
                cache.addToItems(NSOrderedSet(array: feedImages))
                
                try container.viewContext.save()
                completion(.none)
            } catch {
                completion(error)
            }
        } else {
            completion(NSError())
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        if let container = persistentContainer {
            do {
                if let cache: Cache = try container.viewContext.fetch(Cache.fetchRequest()).first {
                    completion(.found(feed: cache.local, timestamp: cache.timestamp!))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        } else {
            completion(.failure(NSError()))
        }
    }
}
