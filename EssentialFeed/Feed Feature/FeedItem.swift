//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 12/15/20.
//

import Foundation

public struct FeedItem: Equatable {
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
