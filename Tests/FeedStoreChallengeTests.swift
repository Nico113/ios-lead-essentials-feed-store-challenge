//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge
import CoreData

class CoreDataFeedStore: FeedStore {
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
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        do {
            try deleteCurrentCache()
            completion(.none)
        } catch {
            completion(error)
        }
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
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
    
    func retrieve(completion: @escaping RetrievalCompletion) {
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

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
    override func setUp() {
        super.setUp()
        
        clearCache()
    }
    
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()
        
        self.assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

        self.assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()

        self.assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}

	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_delete_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}

	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() -> FeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeak(sut)
        return sut
	}
    
    private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated", file: file, line: line)
        }
    }
    
    private func clearCache(file: StaticString = #file, line: UInt = #line) {
        let sut = makeSUT()
        
        sut.deleteCachedFeed { (error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }
	
}
