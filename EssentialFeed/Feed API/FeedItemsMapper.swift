//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 12/21/20.
//

import Foundation

internal final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [Item]
    }

    struct Item: Equatable, Decodable {
        let feedItemId: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            return FeedItem(feedItemId: feedItemId, description: description, location: location, imageURL: image)
        }
    }

    private static var OK_200: Int { 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.RemoteFeedLoaderError.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.feedItem }
        
    }
}
