//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 12/30/20.
//

import Foundation

public class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    
}

extension LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
    public func save(_ feed: [FeedImage]) throws {
        try store.deleteCachedFeed()
        try store.insert(feed.toLocal(), timestamp: currentDate())
    }
}
    
extension LocalFeedLoader: FeedLoader {
    
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        
        do {
            if let cache = try store.retrieve(), !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                completion(.success(cache.feed.toModels()))
            } else {
                completion(.success([]))
            }
        } catch {
            completion(.failure(error))
        }
    }
}

extension LocalFeedLoader {
    
    private struct InvalidCache: Error {}
    
    public func validateCache() throws {
        do {
            if let cache = try store.retrieve(), !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                throw InvalidCache()
            }
                
        } catch {
            try store.deleteCachedFeed()
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(feedId: $0.feedId, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(feedId: $0.feedId, description: $0.description, location: $0.location, url: $0.url) }
    }
}
