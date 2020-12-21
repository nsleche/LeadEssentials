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
            case .success(let response):
                completion(.failure(RemoteFeedLoaderError.invalidData))
            case .failure(let error):
                completion(.failure(RemoteFeedLoaderError.connectivity))
            }
        }
    }
}
