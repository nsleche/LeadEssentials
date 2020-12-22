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
        
        var feed: [FeedItem] {
            return items.map { $0.feedItem }
        }
        
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
    
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.RemoteFeedLoaderResult {
        
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return RemoteFeedLoader.RemoteFeedLoaderResult.failure(.invalidData)
        }
        return RemoteFeedLoader.RemoteFeedLoaderResult.success(root.feed)

    }
}
