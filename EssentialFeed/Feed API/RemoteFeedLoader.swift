//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 12/15/20.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public final class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum RemoteFeedLoaderError: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum RemoteFeedLoaderResult: Equatable {
        case success([FeedItem])
        case failure(RemoteFeedLoaderError)
    }
    
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.RemoteFeedLoaderResult) -> Void) {
        client.get(from: url) { httpClientResult in
            switch httpClientResult {
            case let .success(data, response):
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items.map { $0.feedItem }))
                } else {
                    completion(.failure(RemoteFeedLoaderError.invalidData))
                }
            case .failure:
                completion(.failure(RemoteFeedLoaderError.connectivity))
            }
        }
    }
}

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
