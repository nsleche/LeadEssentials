//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 1/22/21.
//

import Foundation
import CoreData

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public class CoreDataFeedStore {
    
    private static let dataModelName = "FeedStore"
    
    
    let persistentContainer: NSPersistentContainer
    let context: NSManagedObjectContext
    
    public enum StorageType {
        case persistent, inMemory
    }
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storageType: StorageType = .persistent) {
        
        guard let modelURL = Bundle(for: ManagedFeedCache.self).url(forResource: "FeedStore", withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        self.persistentContainer = NSPersistentContainer(name: CoreDataFeedStore.dataModelName, managedObjectModel: model)
        
        if storageType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            self.persistentContainer.persistentStoreDescriptions = [description]
        }
        
        
        
        self.persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("error at loadPersistentStores \(error), \(error.userInfo)")
            }
            
            print("storeDescription", storeDescription)
        }
        
        self.context = persistentContainer.newBackgroundContext()
    }
    
    func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait {
            result = action(context)
        }
        return try result.get()
    }
    
}

