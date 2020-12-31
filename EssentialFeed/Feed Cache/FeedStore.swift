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
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

// this is a DTO
public struct LocalFeedItem: Equatable {
    public let feedItemId: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(feedItemId: UUID, description: String?, location: String?, imageURL: URL) {
        self.feedItemId = feedItemId
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
