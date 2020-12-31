//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 12/30/20.
//

import Foundation

// @learn: this is a DTO kind of object

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
