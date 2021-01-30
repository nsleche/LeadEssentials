//
//  FeedImage.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 12/15/20.
//

import Foundation

public struct FeedImage: Equatable {
    public let feedId: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(feedId: UUID, description: String?, location: String?, url: URL) {
        self.feedId = feedId
        self.description = description
        self.location = location
        self.url = url
    }
}
