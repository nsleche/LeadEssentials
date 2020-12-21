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
}
