//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 12/15/20.
//

import Foundation

public struct FeedItem: Equatable {
    public let feedId: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(feedId: UUID, description: String?, location: String?, imageURL: URL) {
        self.feedId = feedId
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

extension FeedItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case feedId
        case description
        case location
        case imageURL = "image"
    }
}
