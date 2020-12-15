//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 12/15/20.
//

import Foundation

enum LoadFeedResult<T> {
    case success([T])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult<FeedItem>) -> Void)
}
