//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 1/9/21.
//

/*
import Foundation

public class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map {$0.localFeedImage }
        }
    }
    
    private struct CodableFeedImage: Codable {
        public let feedId: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        init(feedImage: LocalFeedImage) {
            self.feedId = feedImage.feedId
            self.description = feedImage.description
            self.location = feedImage.location
            self.url = feedImage.url
        }
        
        var localFeedImage: LocalFeedImage {
            return LocalFeedImage(feedId: feedId, description: description, location: location, url: url)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        let url = self.storeURL
        
        try performSync {
            Result {
                let encoder = JSONEncoder()
                let codableFeedImage = feed.map { CodableFeedImage(feedImage: $0) }
                let encoded = try encoder.encode(Cache(feed: codableFeedImage, timestamp: timestamp))
                try encoded.write(to: url)
            }
        }
    }
    
    private func insertSync(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
        let url = self.storeURL
        
        queue.async(flags: .barrier) {
            let encoder = JSONEncoder()
            let codableFeedImage = feed.map { CodableFeedImage(feedImage: $0) }
            guard let encoded = try? encoder.encode(Cache(feed: codableFeedImage, timestamp: timestamp)) else {
                return completion(nil)
            }
            try? encoded.write(to: url)
            completion(nil)
        }
        
    }
    
    private func execute(completion: @escaping (CachedFeed?) -> Void) {
        let url = self.storeURL
        
        queue.async {
            guard let data = try? Data(contentsOf: url) else {
                return completion(nil)
            }
            
            let decoder = JSONDecoder()
            guard let cache = try? decoder.decode(Cache.self, from: data) else {
                return completion(nil)
            }
            completion(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp))
        }
    }
    
    public func retrieve() throws -> CachedFeed? {
        let url = self.storeURL
        return try performSync {
            Result {
                try CodableFeedStore.find(in: url).map {
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            }
        }

        
    }
    

    
    
    func performSync<R>(_ action: @escaping () -> Result<R, Error>) throws -> R {
        let url = self.storeURL
        var result: Result<R, Error>!
        
        queue.async(flags: .barrier) {
            result = action()
        }
        return try result.get()
    }
    
    
    public func deleteCachedFeed() throws {
        
        deleteSynce { (error) in
            print("error deleting")
        }
        
//        try performSync { storeURL in
//            Result {
//                guard FileManager.default.fileExists(atPath: storeURL.path) else {
//                    throw NSError(domain: "FileDoesNotExist", code: 90990, userInfo: nil)
//                }
//
//                do {
//                    try FileManager.default.removeItem(at: storeURL)
//                } catch {
//                    throw NSError(domain: "ErrorRemovingItem", code: 90990, userInfo: nil)
//                }
//            }
//        }
    }
    
    public func deleteSynce(completion: @escaping (Error?) -> Void) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(nil)
            }
        }
    }
    
}

extension CodableFeedStore {
    static private func find(in url: URL) throws -> Cache? {
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        return try decoder.decode(Cache.self, from: data)
        //completion(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp))
    }
}

 */

