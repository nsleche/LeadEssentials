//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 12/30/20.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias ResultCompletion = (LocalFeedLoader.LoadResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping (LocalFeedLoader.LoadResult) -> Void)
}
