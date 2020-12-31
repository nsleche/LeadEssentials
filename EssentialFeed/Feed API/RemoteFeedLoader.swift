//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 12/15/20.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum RemoteFeedLoaderError: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias RemoteFeedLoaderResult = LoadFeedResult
    
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(from: url) { [weak self] httpClientResult in
            guard self != nil else { return }
            switch httpClientResult {
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data, from: response))
            case .failure:
                completion(.failure(RemoteFeedLoaderError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> LoadFeedResult {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
            return LoadFeedResult.success(items.toModels())
        } catch {
            return LoadFeedResult.failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        return map { FeedItem(feedItemId: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)}
    }
}
